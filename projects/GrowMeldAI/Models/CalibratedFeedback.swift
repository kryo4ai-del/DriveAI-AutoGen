import Foundation

/// Emotionally calibrated feedback with domain-specific narrative
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
    let motivationalBoost: Double // 0.0-1.0
}

enum EmotionalTone: String, Codable {
    case encouraging
    case challenging
    case supportive
    case celebratory
}