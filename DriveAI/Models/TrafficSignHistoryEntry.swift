import Foundation

struct TrafficSignHistoryEntry: Identifiable, Codable {
    let id: UUID
    let signName: String
    let signCategory: TrafficSignCategory
    let explanation: String
    let confidence: Double
    let timestamp: Date
    let imageData: Data?   // JPEG-compressed thumbnail, nil if unavailable

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
         imageData: Data? = nil) {
        self.id = id
        self.signName = signName
        self.signCategory = signCategory
        self.explanation = explanation
        self.confidence = confidence
        self.timestamp = timestamp
        self.imageData = imageData
    }

    /// Convenience init from a recognition result
    init(from result: TrafficSignRecognitionResult) {
        self.init(
            signName: result.signName,
            signCategory: result.signCategory,
            explanation: result.explanation,
            confidence: result.confidence,
            imageData: result.imageData
        )
    }
}
