protocol LocalBackupServiceProtocol {
    func exportBackup() async throws -> (data: Data, fileName: String)
    func importBackup(from data: Data) async throws
    func scheduleLocalBackup()
    func deleteOldBackups()
}

@MainActor
class LocalBackupService: LocalBackupServiceProtocol {
    func exportBackup() async throws -> (data: Data, fileName: String) {
        fatalError("Not implemented")
    }
    
    func importBackup(from data: Data) async throws {
        fatalError("Not implemented")
    }
    
    func scheduleLocalBackup() {
    }
    
    func deleteOldBackups() {
    }
}