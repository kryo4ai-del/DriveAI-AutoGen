protocol LocalBackupServiceProtocol {
    func exportBackup() async throws -> (data: Data, fileName: String)
    func importBackup(from data: Data) async throws
    func scheduleLocalBackup()
    func deleteOldBackups()
}

@MainActor