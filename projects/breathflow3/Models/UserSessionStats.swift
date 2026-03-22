// Models/UserSessionStats.swift
import Foundation

struct UserSessionStats: Codable, Equatable {
    let exerciseId: UUID
    let completedCount: Int
    let averageScore: Double
    let lastAttemptDate: Date?
    let bestScore: Double

    enum CodingKeys: String, CodingKey {
        case exerciseId, completedCount, averageScore, bestScore
        case lastAttemptDate = "last_attempt_date"
    }
}
