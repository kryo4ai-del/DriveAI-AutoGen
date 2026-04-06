@MainActor
final class DefaultFeedbackService: FeedbackService {
    private var feedbackCache: [UUID: UserFeedback] = [:]
    private var cacheInvalidationTask: Task<Void, Never>?
    
    init(persistenceService: FeedbackPersistenceService) {
        self.persistenceService = persistenceService
        // ✅ Start auto-invalidation timer
        startCacheInvalidationTimer()
    }
    
    private func startCacheInvalidationTimer() {
        cacheInvalidationTask?.cancel()
        cacheInvalidationTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 300_000_000_000)  // 5 min
                await MainActor.run {
                    self.feedbackCache.removeAll()
                }
            }
        }
    }
    
    func saveFeedback(_ feedback: UserFeedback) async throws {
        try await persistenceService.save(feedback)
        feedbackCache[feedback.questionID] = feedback
    }
    
    func deleteFeedback(for questionID: UUID) async throws {
        try await persistenceService.delete(for: questionID)
        feedbackCache.removeValue(forKey: questionID)  // ✅ CRITICAL FIX
    }
    
    func getAllFeedback() async throws -> [UserFeedback] {
        let all = try await persistenceService.fetchAll()
        // ✅ Refresh cache with fresh data
        for feedback in all {
            feedbackCache[feedback.questionID] = feedback
        }
        return all
    }
    
    deinit {
        cacheInvalidationTask?.cancel()
    }
}