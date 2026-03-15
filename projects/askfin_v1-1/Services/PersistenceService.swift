// Services/PersistenceService.swift
@MainActor
final class PersistenceService: PersistenceServiceProtocol {
    private let fileManager = FileManager.default
    private let documentsURL: URL
    private let backupManager: BackupManager
    
    private var examSessionsDirectory: URL {
        let dir = documentsURL.appendingPathComponent("exam_sessions")
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    init(documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) {
        self.documentsURL = documentsURL
        self.backupManager = BackupManager(baseURL: documentsURL)
    }
    
    // MARK: - Session Persistence
    
    func saveExamSession(_ session: ExamSession) throws {
        let data = try JSONEncoder().encode(session)
        let fileURL = examSessionsDirectory.appendingPathComponent("exam_\(session.id).json")
        
        // Create backup before write
        if fileManager.fileExists(atPath: fileURL.path) {
            try backupManager.createBackup(of: fileURL, for: session.id)
        }
        
        // Atomic write: temp file → rename
        let tempURL = fileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL, options: .atomic)
        
        try fileManager.removeItem(at: fileURL) // Safe to fail
        try fileManager.moveItem(at: tempURL, to: fileURL)
    }
    
    func loadExamSession(_ id: String) throws -> ExamSession? {
        let fileURL = examSessionsDirectory.appendingPathComponent("exam_\(id).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(ExamSession.self, from: data)
        } catch {
            // Try to recover from latest backup
            if let backup = try backupManager.restoreLatestBackup(for: id, to: fileURL) {
                return try loadExamSession(id) // Retry with restored version
            }
            
            // No recovery possible — log and fail gracefully
            logCorruption(id: id, error: error)
            try fileManager.removeItem(at: fileURL)
            throw PersistenceError.corruptedSession(id: id)
        }
    }
    
    func loadAllExamSessions() throws -> [ExamSession] {
        let fileURLs = try fileManager.contentsOfDirectory(
            at: examSessionsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        )
        
        return try fileURLs
            .filter { $0.lastPathComponent.hasPrefix("exam_") }
            .compactMap { fileURL in
                do {
                    let data = try Data(contentsOf: fileURL)
                    return try JSONDecoder().decode(ExamSession.self, from: data)
                } catch {
                    logCorruption(id: fileURL.lastPathComponent, error: error)
                    return nil
                }
            }
            .sorted { $0.startTime > $1.startTime }
    }
    
    // MARK: - Progress Persistence
    
    func saveUserProgress(_ progress: UserProgress) throws {
        let data = try JSONEncoder().encode(progress)
        let fileURL = documentsURL.appendingPathComponent("user_progress.json")
        
        let tempURL = fileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL, options: .atomic)
        try fileManager.removeItem(at: fileURL)
        try fileManager.moveItem(at: tempURL, to: fileURL)
    }
    
    func loadUserProgress() throws -> UserProgress? {
        let fileURL = documentsURL.appendingPathComponent("user_progress.json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(UserProgress.self, from: data)
        } catch {
            logCorruption(id: "user_progress", error: error)
            try fileManager.removeItem(at: fileURL)
            return UserProgress() // Return default progress
        }
    }
    
    // MARK: - Error Handling
    
    private func logCorruption(id: String, error: Error) {
        #if DEBUG
        print("⚠️ Corrupted data '\(id)': \(error.localizedDescription)")
        #endif
    }
}

// MARK: - Backup Manager

@MainActor
final class BackupManager {
    private let fileManager = FileManager.default
    private let baseURL: URL
    
    private var backupDirectory: URL {
        let dir = baseURL.appendingPathComponent(".backups")
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func createBackup(of fileURL: URL, for sessionId: String) throws {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let backupName = "exam_\(sessionId)_\(timestamp).json.bak"
        let backupURL = backupDirectory.appendingPathComponent(backupName)
        
        try fileManager.copyItem(at: fileURL, to: backupURL)
        
        // Keep only last 5 backups per session
        try pruneOldBackups(for: sessionId, keepCount: 5)
    }
    
    func restoreLatestBackup(for sessionId: String, to destinationURL: URL) throws -> Bool {
        let prefix = "exam_\(sessionId)_"
        let backups = try fileManager.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: nil)
        
        let latestBackup = backups
            .filter { $0.lastPathComponent.hasPrefix(prefix) }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
            .first
        
        guard let backup = latestBackup else {
            return false
        }
        
        try fileManager.copyItem(at: backup, to: destinationURL)
        return true
    }
    
    private func pruneOldBackups(for sessionId: String, keepCount: Int) throws {
        let prefix = "exam_\(sessionId)_"
        let backups = try fileManager.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: nil)
        
        let sorted = backups
            .filter { $0.lastPathComponent.hasPrefix(prefix) }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
        
        for backup in sorted.dropFirst(keepCount) {
            try fileManager.removeItem(at: backup)
        }
    }
}
