import Observation

@Observable
final class BackupServiceObservable {
    var isBackupInProgress = false
    var lastError: BackupError?
    var lastBackupMetadata: [BackupMetadata] = []
    
    private let service: BackupService
    
    func performBackup() async throws {
        isBackupInProgress = true
        defer { isBackupInProgress = false }
        try await service.createBackup()
    }
}