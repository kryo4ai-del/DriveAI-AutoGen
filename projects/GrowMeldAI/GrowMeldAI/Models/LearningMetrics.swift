// Domain/Domains/LearningAlgorithm.swift

import Foundation

struct LearningMetrics {
    let questionID: String
    let isCorrect: Bool
    let timeTaken: TimeInterval
    let nextReviewDate: Date
    let difficulty: Double  // 0.0 to 1.0
    let masteryScore: Double  // 0.0 to 1.0
    let timestamp: Date
}
