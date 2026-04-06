import Foundation

@MainActor
protocol ASODataServiceProtocol: AnyObject {
    /// Refresh all metrics from APIs and cache locally
    func refreshAllMetrics() async throws
    
    /// Get keyword metrics (from cache or fetch)
    func getKeywordMetrics() async throws -> [KeywordMetric]
    
    /// Get review data with sentiment analysis
    func getReviews(limit: Int) async throws -> [ReviewAnalysis]
    
    /// Get competitor snapshots
    func getCompetitors() async throws -> [CompetitorSnapshot]
    
    /// Get AI-driven recommendations
    func getRecommendations() async throws -> [ASORecommendation]
    
    /// Get performance metrics (downloads, rating, etc.)
    func getPerformanceMetrics() async throws -> [PerformanceMetric]
    
    /// Track a new keyword
    func addKeywordToTrack(_ keyword: String) async throws
    
    /// Dismiss a recommendation
    func dismissRecommendation(_ id: UUID) async throws
}

@MainActor
protocol KeywordServiceProtocol: AnyObject {
    func fetchLatestMetrics() async throws -> [KeywordMetric]
    func getRankHistory(for keyword: String) async throws -> [RankSnapshot]
    func getCompetitorRanks(for keyword: String) async throws -> [String: Int]
}

@MainActor
protocol ReviewServiceProtocol: AnyObject {
    func fetchLatestReviews(limit: Int) async throws -> [ReviewAnalysis]
    func analyzeSentiment(text: String) async -> ReviewAnalysis.Sentiment
    func getTopics(from review: ReviewAnalysis) async -> [ReviewAnalysis.ReviewTopic]
}

@MainActor
protocol CompetitorServiceProtocol: AnyObject {
    func fetchCompetitorSnapshots() async throws -> [CompetitorSnapshot]
    func getCompetitorDetails(appID: String) async throws -> CompetitorSnapshot
}

@MainActor
protocol RecommendationServiceProtocol: AnyObject {
    func generateRecommendations() async throws -> [ASORecommendation]
    func prioritizeRecommendations(_ recs: [ASORecommendation]) -> [ASORecommendation]
}