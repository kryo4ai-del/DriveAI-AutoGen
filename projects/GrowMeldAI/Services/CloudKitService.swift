class CloudKitService {
    func uploadProgress(_ data: ProgressSnapshot) async throws
    func downloadLatestProgress() async throws -> ProgressSnapshot?
    func syncOnChange() // Observe local changes
    func handleConflicts() // Merge strategy
  }