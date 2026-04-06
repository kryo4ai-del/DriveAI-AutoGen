import Foundation

struct UserStatistics: Codable {
    let totalAttempts: Int
    let correctAttempts: Int
    let averageScore: Double
    let lastSyncDate: Date?
}

struct QuestionAttempt: Codable {
    let questionId: Int
    let category: String
    let isCorrect: Bool
    let attemptedAt: Date
    let timeSpentSeconds: Double
}

enum BackendType: String, Codable {
    case local
    case firebase
    case rest
    case graphQL
}

protocol DataBackend {
    func syncProgress(category: String) async throws
    func fetchStatistics() async throws -> UserStatistics
    func uploadAttempt(_ attempt: QuestionAttempt) async throws
    func getAvailableBackends() -> [BackendType]
}