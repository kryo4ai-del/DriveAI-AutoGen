import Foundation

final class LocalOnlyDataSync: DataSyncService {
    private let localDataService: LocalDataService

    init(localDataService: LocalDataService = LocalDataService.shared) {
        self.localDataService = localDataService
    }

    func uploadExamResult(_ result: ExamResult) async throws {
        do {
            try localDataService.saveExamResult(result)
        } catch {
            throw DataSyncError.localStorageFailed
        }
    }

    func syncQuestionCatalog() async throws {
        // No-op for local-only implementation
    }
}