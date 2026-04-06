import Foundation

final class FirebaseDataSync: DataSyncService {
    private let firebaseManager: FirebaseManager

    init(firebaseManager: FirebaseManager = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }

    func uploadExamResult(_ result: ExamResult) async throws {
        // Implementation deferred until Firebase integration
        throw DataSyncError.networkUnavailable
    }

    func syncQuestionCatalog() async throws {
        // Implementation deferred until Firebase integration
        throw DataSyncError.networkUnavailable
    }
}