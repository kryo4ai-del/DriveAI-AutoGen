import Foundation

/// Aggregated retention metrics for reporting
struct RetentionMetrics: Codable {
    let totalQuestionsTracked: Int
    let dueForReview: Int
    let recentlyMastered: Int
    let strugglingQuestions: Int
    
    let overallAccuracy: Double
    let reviewStreak: Int
    let lastReviewDate: Date?
    
    // Category breakdown
    let byCategory: [String: CategoryMetrics]
    
    struct CategoryMetrics: Codable {
        let categoryId: String
        let tracked: Int
        let accuracy: Double
        let dueCount: Int
    }
}