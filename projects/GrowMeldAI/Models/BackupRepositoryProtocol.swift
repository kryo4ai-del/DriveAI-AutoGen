protocol BackupRepositoryProtocol {
    func saveBackup(_ backup: UserBackup) async throws
    func loadBackup() async throws -> UserBackup?
}
