class MockBackupRepository: LocalBackupRepository {
    var saveWasCalled = false
    var loadWasCalled = false
    var mockBackup: UserBackup?
    var mockError: BackupError?
    
    override func saveBackup(_ backup: UserBackup) async throws {
        saveWasCalled = true
        if let error = mockError { throw error }
    }
    
    override func loadBackup() async throws -> UserBackup? {
        loadWasCalled = true
        if let error = mockError { throw error }
        return mockBackup
    }
}