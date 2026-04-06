import Foundation

struct ReviewSchedule: Codable, Equatable {
    let nextReviewDate: Date
    let interval: TimeInterval
    let difficulty: Double
    let attemptCount: Int
}