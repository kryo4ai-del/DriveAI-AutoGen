// Domain/BackupSystem/Services/BackupValidationService.swift

import Foundation

/// Handles validation of backup data before persistence
struct BackupValidationService {
    
    enum ValidationError: String, Error {
        case emptyUserData = "User data is empty"
        case invalidExamDate = "Exam date is not valid"
        case invalidScore = "Score is out of valid range"
        case negativeQuestionCount = "Question count cannot be negative"
        case invalidCategoryData = "Category data is malformed"
    }
    
    // MARK: - Public Methods
    
    /// Validates complete user backup before saving
    static func validate(_ backup: UserBackup) throws {
        try validateExamDate(backup.examDate)
        try validateScore(backup.overallScore)
        try validateQuestionCount(backup.totalQuestionsAnswered)
        try validateCategoryProgress(backup.categoryProgress)
    }
    
    /// Validates exam date
    static func validateExamDate(_ date: Date) throws {
        guard date > Date() else {
            throw BackupError.invalidExamDate("Prüfungsdatum muss in der Zukunft liegen")
        }
        
        let maxDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        guard date <= maxDate else {
            throw BackupError.invalidExamDate("Prüfungsdatum ist zu weit in der Zukunft")
        }
    }
    
    /// Validates overall score
    static func validateScore(_ score: Int) throws {
        guard (0...100).contains(score) else {
            throw BackupError.invalidData("Score muss zwischen 0 und 100 liegen")
        }
    }
    
    /// Validates question count
    static func validateQuestionCount(_ count: Int) throws {
        guard count >= 0 else {
            throw BackupError.invalidData("Fragenzahl kann nicht negativ sein")
        }
    }
    
    /// Validates category progress data
    static func validateCategoryProgress(_ categories: [CategoryProgress]) throws {
        for category in categories {
            guard !category.categoryName.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw BackupError.invalidData("Kategorienamen darf nicht leer sein")
            }
            
            guard category.questionsCorrect <= category.questionsTotal else {
                throw BackupError.invalidData("Korrekte Antworten können nicht mehr als Gesamtzahl sein")
            }
            
            guard category.questionsCorrect >= 0 && category.questionsTotal >= 0 else {
                throw BackupError.invalidData("Fragenzahl kann nicht negativ sein")
            }
        }
    }
    
    /// Checks if backup file is readable
    static func validateBackupFile(at url: URL) throws {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path) else {
            throw BackupError.fileNotFound
        }
        
        guard fileManager.isReadableFile(atPath: url.path) else {
            throw BackupError.fileAccessDenied("Sicherungsdatei ist nicht lesbar")
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // Sanity check: backup should be > 100 bytes, < 10 MB
            guard fileSize > 100 && fileSize < 10_485_760 else {
                throw BackupError.corruptedBackupFile("Dateigröße ist verdächtig")
            }
        } catch {
            throw BackupError.fileAccessDenied(error.localizedDescription)
        }
    }
}