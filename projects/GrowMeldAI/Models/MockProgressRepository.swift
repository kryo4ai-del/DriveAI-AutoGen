#if DEBUG
final class MockProgressRepository: ProgressRepository {
    var progress: [String: UserProgressDomain] = [:]
    var saveProgressCallCount = 0
    
    func saveProgress(_ progress: UserProgressDomain) async throws {
        saveProgressCallCount += 1
        self.progress[progress.id] = progress
    }
    
    func getProgress(userId: String, categoryId: QuestionDomain.QuestionCategory) async throws -> UserProgressDomain? {
        progress.values.first { $0.userId == userId && $0.categoryId == categoryId }
    }
    
    func getUserProgress(userId: String) async throws -> [UserProgressDomain] {
        Array(progress.values.filter { $0.userId == userId })
    }
    
    func deleteProgress(userId: String, categoryId: QuestionDomain.QuestionCategory) async throws {
        progress.removeAll { $0.userId == userId && $0.categoryId == categoryId }
    }
}
#endif