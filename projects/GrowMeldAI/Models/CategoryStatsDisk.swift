actor PerformanceStore {
    private struct CategoryStatsDisk: Codable {
        let categoryID: String
        let totalAttempts: Int
        let correctAttempts: Int
        let lastUpdated: Date
        let averageTimePerQuestion: TimeInterval
    }
    
    private var statsCache: [String: CategoryStatsDisk] = [:]
    private let statsCacheTTL: TimeInterval = 300  // 5 minutes
    
    /// Fetch cached stats (refresh only if > 5 min old)
    func fetchCategoryStats(categoryID: String) async throws -> CategoryStats {
        // Check cache freshness
        if let cached = statsCache[categoryID],
           Date().timeIntervalSince(cached.lastUpdated) < statsCacheTTL {
            return categoryStatsFromDisk(cached)
        }
        
        // Compute from recent attempts only (last 100)
        let attempts = try await fetchAttempts(categoryID: categoryID, limit: 100)
        let stats = computeStatsFromAttempts(attempts)
        
        // Cache
        statsCache[categoryID] = CategoryStatsDisk(
            categoryID: categoryID,
            totalAttempts: stats.totalAttempts,
            correctAttempts: stats.correctAttempts,
            lastUpdated: Date(),
            averageTimePerQuestion: stats.averageTimePerQuestion
        )
        
        try await persistCategoryStats()
        return stats
    }
    
    /// Invalidate cache when new attempt recorded
    func recordAttemptAndInvalidateStats(_ attempt: QuestionAttempt) async throws {
        try await saveQuestionAttempt(attempt)
        statsCache.removeValue(forKey: attempt.categoryID)
    }
}