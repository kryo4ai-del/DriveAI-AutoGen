@MainActor
final class BackupDomainService {
    func performBackup(examContext: BackupExamContext) async -> BackupResult {
        let progressData = try await progressService.exportProgressData()  // Must be async
        // But is progressService also @MainActor?
    }
}