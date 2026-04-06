import Foundation

enum ExamReadinessTier: Equatable {
    case needsWork(questionsRemaining: Int)
    case makingProgress(confidenceLevel: String)
    case almostReady(daysUntilExam: Int)
    case ready
}

enum TemporalZone {
    case earlyStage      // 90+ days
    case buildingPhase   // 30-90 days
    case finalPush       // 7-30 days
    case lastMinute      // <7 days
}

struct ExamReadinessAssessment {
    let tier: ExamReadinessTier
    let temporalZone: TemporalZone
    let motivationalText: String
    let primaryCTA: StudyOption?
    let nextOptimalReviewCategories: [String]
}