protocol CloudKitServiceProtocol {
    func uploadProgress(_ progress: ProgressSnapshot) async throws
    func downloadLatestProgress() async throws -> ProgressSnapshot?
    func observeRemoteChanges() async
    func resolveConflict(local: ProgressSnapshot, cloud: ProgressSnapshot) -> ProgressSnapshot
}