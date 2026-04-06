import Foundation

// MARK: - Value Objects & Aggregates

/// Backup retention policy — defines how long backups persist
public enum BackupRetentionPolicy: Codable, Equatable, Hashable {
    case untilExamDate
    case daysAfterExam(days: Int)
    case indefinite
    case userControlled
    
    var description: String {
        switch self {
        case .untilExamDate:
            return "Bis zur Fahrprüfung"
        case .daysAfterExam(let days):
            return "Für \(days) Tage nach der Prüfung"
        case .indefinite:
            return "Unbegrenzt"
        case .userControlled:
            return "Nach Nutzer-Anfrage"
        }
    }
}

/// Backup trigger frequency — when backups should occur
public enum BackupTriggerPolicy: Codable, Equatable, Hashable {
    case automatic        // After each exam session
    case daily
    case weekly
    case manual           // User-initiated only
    case onExamProximity  // 7 days before exam
    
    var description: String {
        switch self {
        case .automatic:
            return "Nach jeder Trainingssitzung"
        case .daily:
            return "Täglich"
        case .weekly:
            return "Wöchentlich"
        case .manual:
            return "Manuell"
        case .onExamProximity:
            return "Vor der Prüfung"
        }
    }
}

/// User's exam readiness metrics — domain logic anchors to these
public struct ExamReadinessMetrics: Codable, Equatable {
    public let progressPercent: Double          // 0-100: % of questions attempted
    public let correctAnswerRate: Double        // 0-100: % correct of attempted
    public let currentStreak: Int               // Consecutive correct answers
    public let weakCategories: [String]         // Categories below 70% accuracy
    public let sessionCount: Int                // Total practice sessions
    public let lastSessionDate: Date?
    
    public init(
        progressPercent: Double,
        correctAnswerRate: Double,
        currentStreak: Int,
        weakCategories: [String],
        sessionCount: Int,
        lastSessionDate: Date? = nil
    ) {
        self.progressPercent = progressPercent
        self.correctAnswerRate = correctAnswerRate
        self.currentStreak = currentStreak
        self.weakCategories = weakCategories
        self.sessionCount = sessionCount
        self.lastSessionDate = lastSessionDate
    }
    
    /// Calculate readiness score (0-100) — used to prioritize backup frequency
    public func readinessScore() -> Double {
        let progressWeight = 0.3
        let accuracyWeight = 0.5
        let consistencyWeight = 0.2
        
        let consistencyScore = min(Double(sessionCount) / 10.0 * 100, 100) // Favor multiple sessions
        
        return (progressPercent * progressWeight) +
               (correctAnswerRate * accuracyWeight) +
               (consistencyScore * consistencyWeight)
    }
}

/// Exam context — ties backup behavior to exam date and readiness
public struct BackupExamContext: Codable, Equatable {
    public let examDate: Date
    public let readinessMetrics: ExamReadinessMetrics
    public let retentionPolicy: BackupRetentionPolicy
    public let triggerPolicy: BackupTriggerPolicy
    public let allowUserDeletion: Boolean
    
    public let lastBackupDate: Date?
    public let nextScheduledBackupDate: Date?
    
    public init(
        examDate: Date,
        readinessMetrics: ExamReadinessMetrics,
        retentionPolicy: BackupRetentionPolicy = .daysAfterExam(days: 30),
        triggerPolicy: BackupTriggerPolicy = .automatic,
        allowUserDeletion: Boolean = true,
        lastBackupDate: Date? = nil,
        nextScheduledBackupDate: Date? = nil
    ) {
        self.examDate = examDate
        self.readinessMetrics = readinessMetrics
        self.retentionPolicy = retentionPolicy
        self.triggerPolicy = triggerPolicy
        self.allowUserDeletion = allowUserDeletion
        self.lastBackupDate = lastBackupDate
        self.nextScheduledBackupDate = nextScheduledBackupDate
    }
    
    // MARK: Domain Logic
    
    /// Determine if backup should be triggered automatically
    public func shouldTriggerAutoBackup() -> Boolean {
        switch triggerPolicy {
        case .manual:
            return false
            
        case .automatic:
            // Auto-backup after exam session (assumed to be called post-session)
            return true
            
        case .daily:
            guard let lastBackup = lastBackupDate else { return true }
            return Calendar.current.isDateInYesterday(lastBackup) ||
                   Calendar.current.isDateInToday(lastBackup) == false
            
        case .weekly:
            guard let lastBackup = lastBackupDate else { return true }
            return daysSinceLastBackup() >= 7
            
        case .onExamProximity:
            return daysUntilExam() <= 7 && lastBackupDate == nil
        }
    }
    
    /// Calculate days until exam (negative if exam is in past)
    public func daysUntilExam() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: examDate)
        return components.day ?? 0
    }
    
    /// Calculate days since last backup
    public func daysSinceLastBackup() -> Int {
        guard let lastBackup = lastBackupDate else { return Int.max }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastBackup, to: Date())
        return components.day ?? 0
    }
    
    /// Determine when backup should be auto-deleted based on policy
    public func calculateAutoDeleteDate() -> Date? {
        switch retentionPolicy {
        case .untilExamDate:
            return examDate
            
        case .daysAfterExam(let days):
            var dateComponents = DateComponents()
            dateComponents.day = days
            return Calendar.current.date(byAdding: dateComponents, to: examDate)
            
        case .indefinite, .userControlled:
            return nil
        }
    }
    
    /// Check if backup should be auto-deleted (expired)
    public func isBackupExpired(backupDate: Date) -> Boolean {
        guard let deleteDate = calculateAutoDeleteDate() else { return false }
        return Date() > deleteDate
    }
    
    /// Generate human-readable backup status message (German)
    public func backupStatusMessage() -> String {
        let daysUntil = daysUntilExam()
        let daysSince = daysSinceLastBackup()
        
        if daysUntil < 0 {
            return "Prüfung abgeschlossen — Backup wird bald gelöscht"
        }
        
        if let lastBackup = lastBackupDate {
            if daysSince == 0 {
                return "Letzter Backup: heute"
            } else if daysSince == 1 {
                return "Letzter Backup: gestern"
            } else {
                return "Letzter Backup: vor \(daysSince) Tagen"
            }
        }
        
        return "Kein Backup vorhanden"
    }
    
    /// Readiness-based backup recommendation (domain psychology)
    public func backupRecommendation() -> String {
        let readiness = readinessMetrics.readinessScore()
        let daysUntil = daysUntilExam()
        
        if daysUntil < 0 {
            return "Du hast deine Prüfung absolviert! 🎉"
        }
        
        if readiness < 50 {
            return "Deine Vorbereitung ist noch am Anfang. Ein Backup schützt deinen Fortschritt."
        }
        
        if readiness > 75 && daysUntil <= 7 {
            return "Du bist gut vorbereitet! Mach ein Backup vor der Prüfung."
        }
        
        if !readinessMetrics.weakCategories.isEmpty {
            let weak = readinessMetrics.weakCategories.prefix(2).joined(separator: ", ")
            return "Achte auf: \(weak). Dein Backup ist aktuell."
        }
        
        return "Deine Vorbereitung ist aktuell — dein Backup schützt deinen Fortschritt."
    }
}

// MARK: - Backup Data Structure

/// Versioned backup metadata — enables schema evolution

/// Complete backup payload — user progress + metadata

/// Backed-up user progress
public struct ProgressBackupData: Codable, Equatable {
    public let answeredQuestionIds: [String]  // Question IDs user has answered
    public let correctAnswerIds: [String]     // Subset of answered that were correct
    public let categoryStats: [String: CategoryStat]  // Per-category accuracy
    public let currentStreak: Int
    public let sessionHistory: [SessionSnapshot]
    
    public init(
        answeredQuestionIds: [String],
        correctAnswerIds: [String],
        categoryStats: [String: CategoryStat],
        currentStreak: Int,
        sessionHistory: [SessionSnapshot]
    ) {
        self.answeredQuestionIds = answeredQuestionIds
        self.correctAnswerIds = correctAnswerIds
        self.categoryStats = categoryStats
        self.currentStreak = currentStreak
        self.sessionHistory = sessionHistory
    }
}

public struct CategoryStat: Codable, Equatable {
    public let categoryId: String
    public let categoryName: String
    public let correct: Int
    public let total: Int
    
    public var accuracy: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
    
    public init(categoryId: String, categoryName: String, correct: Int, total: Int) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.correct = correct
        self.total = total
    }
}

public struct SessionSnapshot: Codable, Equatable {
    public let sessionId: String
    public let date: Date
    public let correctCount: Int
    public let totalCount: Int
    public let categoryId: String?
    
    public init(sessionId: String, date: Date, correctCount: Int, totalCount: Int, categoryId: String? = nil) {
        self.sessionId = sessionId
        self.date = date
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.categoryId = categoryId
    }
}

/// Backed-up user profile
public struct ProfileBackupData: Codable, Equatable {
    public let userName: String
    public let examDate: Date
    public let licenseCategory: String  // "AM", "A1", "A", "B", etc.
    
    public init(userName: String, examDate: Date, licenseCategory: String = "B") {
        self.userName = userName
        self.examDate = examDate
        self.licenseCategory = licenseCategory
    }
}

// MARK: - Backup Result Type

public enum BackupResult: Equatable {
    case success(date: Date, dataSize: Int)
    case failure(BackupError)
}

// MARK: - Restore Result Type

public enum RestoreResult: Equatable {
    case success(dataSize: Int)
    case failure(RestoreError)
}

public enum RestoreError: Error, Equatable {
    case decryptionFailed(String)
    case fileNotFound
    case corruptedData(String)
    case versionMismatch(String)
    case integrityCheckFailed
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .decryptionFailed(let msg):
            return "Entschlüsselung fehlgeschlagen: \(msg)"
        case .fileNotFound:
            return "Backup-Datei nicht gefunden"
        case .corruptedData(let msg):
            return "Backup-Datei beschädigt: \(msg)"
        case .versionMismatch(let msg):
            return "Backup-Version nicht kompatibel: \(msg)"
        case .integrityCheckFailed:
            return "Backup-Integrität konnte nicht verifiziert werden"
        case .unknown(let msg):
            return "Restore-Fehler: \(msg)"
        }
    }
}