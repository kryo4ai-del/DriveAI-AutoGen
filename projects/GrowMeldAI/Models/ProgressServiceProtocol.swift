@MainActor
protocol ProgressServiceProtocol: AnyObject {
    /// Must be callable from MainActor
    func exportProgressData() async throws -> ProgressBackupData
    func importProgressData(_ data: ProgressBackupData) async throws
}

@MainActor
protocol UserServiceProtocol: AnyObject {
    func exportProfileData() async throws -> ProfileBackupData
    func importProfileData(_ data: ProfileBackupData) async throws
}

@MainActor