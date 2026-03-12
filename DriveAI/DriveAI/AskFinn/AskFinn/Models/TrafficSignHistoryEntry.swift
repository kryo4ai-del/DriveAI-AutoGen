import Foundation

struct TrafficSignHistoryEntry: Identifiable, Codable {
    let id: UUID
    let signName: String
    let signCategory: TrafficSignCategory
    let explanation: String
    let confidence: Double
    let timestamp: Date
    let imageData: Data?   // JPEG-compressed thumbnail, nil if unavailable

    // Learning mode fields — nil when entry was created in Assist mode
    let userSelectedMeaning: String?
    let userAnswerCorrect: Bool?
    var wasLearningMode: Bool { userSelectedMeaning != nil }

    var confidencePercentage: Int { Int(confidence * 100) }

    var confidenceLabel: String {
        switch confidence {
        case 0.75...: return "High"
        case 0.40...: return "Medium"
        default:      return "Low"
        }
    }

    init(id: UUID = UUID(),
         signName: String,
         signCategory: TrafficSignCategory,
         explanation: String,
         confidence: Double,
         timestamp: Date = Date(),
         imageData: Data? = nil,
         userSelectedMeaning: String? = nil,
         userAnswerCorrect: Bool? = nil) {
        self.id = id
        self.signName = signName
        self.signCategory = signCategory
        self.explanation = explanation
        self.confidence = confidence
        self.timestamp = timestamp
        self.imageData = imageData
        self.userSelectedMeaning = userSelectedMeaning
        self.userAnswerCorrect = userAnswerCorrect
    }

    /// Convenience init from a recognition result (Assist mode)
    init(from result: TrafficSignRecognitionResult) {
        self.init(
            signName: result.signName,
            signCategory: result.signCategory,
            explanation: result.explanation,
            confidence: result.confidence,
            imageData: result.imageData
        )
    }

    /// Convenience init from a recognition result with learning mode data
    init(from result: TrafficSignRecognitionResult,
         userSelectedMeaning: String,
         userAnswerCorrect: Bool) {
        self.init(
            signName: result.signName,
            signCategory: result.signCategory,
            explanation: result.explanation,
            confidence: result.confidence,
            imageData: result.imageData,
            userSelectedMeaning: userSelectedMeaning,
            userAnswerCorrect: userAnswerCorrect
        )
    }
}
