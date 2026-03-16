import Foundation

protocol LocalDataServiceProtocol: Sendable {
    func fetchAllQuestions() async throws -> [Question]
    func fetchQuestionsByCategory(_ categoryId: String) async throws -> [Question]
    func fetchCategory(byId: String) async throws -> QuestionCategory?
    func getCategoryStatistics() async throws -> [CategoryStat]
    func getTotalTimeSpentMinutes() async throws -> Int
    func getLearningStreakData() async throws -> ReadinessStreakData
    func getRecentPerformanceMetrics() async throws -> RecentMetrics
}

struct QuestionCategory: Identifiable, Codable {
    let id: String
    let name: String
}