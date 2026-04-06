@MainActor
final class PerformanceStateManager: ObservableObject {
    func recordQuestionAttempt(...) async {
        let attempt = QuestionAttempt(...)
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
    func invalidate() async {
        metricsCache = nil
        recentAttemptsCache.removeAll()
    }
}