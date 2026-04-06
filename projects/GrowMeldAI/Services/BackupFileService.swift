import Foundation

protocol BackupFileService: AnyObject {
    func saveBackup(encrypted: Data) throws -> String
    func loadLatestBackup() throws -> Data?
    func deleteLatestBackup() throws
    func getFileSize(at path: String) throws -> Int
    func getLatestBackupDate() -> Date?
}

@MainActor
final class FileSystemBackupService: BackupFileService {
    private let fileManager = FileManager.default
    
    private var backupDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let backupDir = appSupport.appendingPathComponent("Backups", isDirectory: true)
        try? fileManager.createDirectory(at: backupDir, withIntermediateDirectories: true)
        return backupDir
    }
    
    private var latestBackupPath: URL {
        backupDirectory.appendingPathComponent("latest.backup.enc")
    }
    
    func saveBackup(encrypted: Data) throws -> String {
        try encrypted.write(to: latestBackupPath, options: .atomic)
        return latestBackupPath.path
    }
    
    func loadLatestBackup() throws -> Data? {
        guard fileManager.fileExists(atPath: latestBackupPath.path) else { return nil }
        return try Data(contentsOf: latestBackupPath)
    }
    
    func deleteLatestBackup() throws {
        try fileManager.removeItem(at: latestBackupPath)
    }
    
    func getFileSize(at path: String) throws -> Int {
        let attributes = try fileManager.attributesOfItem(atPath: path)
        return attributes[.size] as? Int ?? 0
    }
    
    func getLatestBackupDate() -> Date? {
        let attributes = try? fileManager.attributesOfItem(atPath: latestBackupPath.path)
        return attributes?[.modificationDate] as? Date
    }
}