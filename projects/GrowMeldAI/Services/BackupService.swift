// Services/Backup/BackupService.swift

import Foundation

/// Main backup service protocol
protocol BackupService: AnyObject, Sendable {
    /// Create a backup snapshot of all user data
    func createBackup() async throws -> BackupSnapshot
    
    /// Restore user data from a backup snapshot
    func restoreBackup(_ snapshot: BackupSnapshot) async throws
    
    /// Get list of available backups with metadata
    func getBackupMetadata() async -> [BackupMetadata]
    
    /// Delete a specific backup by ID
    func deleteBackup(_ id: String) async throws
    
    /// Remove old backups beyond retention count
    func pruneOldBackups(keepCount: Int) async throws
}