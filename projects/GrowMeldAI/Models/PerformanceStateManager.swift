@MainActor
final class PerformanceStateManager: ObservableObject {
    func recordQuestionAttempt(questionId: String, isCorrect: Bool, timeSpent: TimeInterval) async {
        let attempt = QuestionAttempt(questionId: questionId, isCorrect: isCorrect, timeSpent: timeSpent)
        dispatch(.recordQuestionAttempt(attempt))
        
        do {
            // Properly await actor method
            try await performanceService.recordQuestionAttempt(attempt)
            await cacheService.invalidate()
        } catch {
            dispatch(.setError(error))
        }
    }
}

// PerformanceCache is a proper actor
actor PerformanceCache {
    private var metricsCache: Any?
    private var recentAttemptsCache: [Any] = []

    func invalidate() {
        metricsCache = nil
        recentAttemptsCache.removeAll()
    }
}