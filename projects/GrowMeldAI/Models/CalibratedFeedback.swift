import Foundation

struct CalibratedFeedback: Codable {
    let correctness: Bool
    let explanation: String
    let narrative: FeedbackNarrative
    let suggestedNextAction: String
    let confidence: Double
    let misconceptionId: String?
}

struct FeedbackNarrative: Codable {
    let primaryMessage: String
    let secondaryMessage: String?
    let tone: EmotionalTone
    let motivationalBoost: Double
}

enum EmotionalTone: String, Codable {
    case encouraging
    case challenging
    case supportive
    case celebratory
}