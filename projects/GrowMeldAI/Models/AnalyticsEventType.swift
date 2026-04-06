// Modules/Analytics/Models/AnalyticsEvent.swift

import Foundation

enum AnalyticsEventType: String, Codable {
    case confidentAnswer = "confident_answer"
    case hesitantAnswer = "hesitant_answer"
    case examApproach = "exam_approach"
    case examTriumph = "exam_triumph"
    case examFailed = "exam_failed"
    case questionReview = "question_review"
    case categoryStarted = "category_started"
    case streakMilestone = "streak_milestone"
}

struct AnalyticsInsights {
    let passed: Bool
    let score: Int
    let timeTakenSeconds: Int
    let confidenceRatio: Double // 0.0–1.0
    let weakCategories: [String]
    let motivationalMessage: String
    let streakCount: Int
}