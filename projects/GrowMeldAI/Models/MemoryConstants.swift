enum MemoryConstants {
    static let masteryTrendDays = 14
    static let targetWeeklyReviews = 50
    static let struggleLowerBound: Double = 0.5
    static let confidenceWeighting: Double = 0.3
}

// Use:
let dailyStats: [Int] = [] // sorted
let recentReviewCount = 0
let confidenceFactor = min(Double(recentReviewCount) / Double(MemoryConstants.targetWeeklyReviews), 1.0)