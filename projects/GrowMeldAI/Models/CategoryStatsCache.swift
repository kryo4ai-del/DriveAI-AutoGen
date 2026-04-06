actor PerformanceStore {
    private struct CategoryStatsCache: Codable {
        let categoryID: String
        let totalAttempts: Int
        let correctAttempts: Int
        let lastUpdated: Date
        let averageTimePerQuestion: TimeInterval
    }
    
    private var categoryStatsCache: [String: CategoryStatsCache] = [:]
    
    func fetchCategoryStats(categoryID: String) async throws -> CategoryStats {
        // Return cached if recent (< 1 minute old)
        if let cached = categoryStatsCache[categoryID],
           Date().timeIntervalSince(cached.lastUpdated) < 60 {
            return CategoryStats(
                categoryID: categoryID,
                totalAttempts: cached.totalAttempts,
                correctAttempts: cached.correctAttempts,
                lastReviewDate: cached.lastUpdated,
                averageTimePerQuestion: cached.averageTimePerQuestion
            )
        }
        
        // Compute and cache
        let attempts = try await fetchAttempts(categoryID: categoryID)
        let stats = computeStatsFromAttempts(attempts)
        categoryStatsCache[categoryID] = CategoryStatsCache(
            categoryID: categoryID,
            totalAttempts: stats.totalAttempts,
            correctAttempts: stats.correctAttempts,
            lastUpdated: Date(),
            averageTimePerQuestion: stats.averageTimePerQuestion
        )
        try await persistCategoryStats()
        return stats
    }
    
    private func computeStatsFromAttempts(_ attempts: [QuestionAttempt]) -> CategoryStats {
        let correct = attempts.filter(\.isCorrect).count
        let totalTime = attempts.map(\.timeSpent).reduce(0, +)
        let avgTime = attempts.isEmpty ? 0 : totalTime / TimeInterval(attempts.count)
        
        return CategoryStats(
            categoryID: attempts.first?.categoryID ?? "",
            totalAttempts: attempts.count,
            correctAttempts: correct,
            lastReviewDate: attempts.last?.attemptDate,
            averageTimePerQuestion: avgTime
        )
    }
}