import Foundation

struct TrafficSignRecognitionResult {
    let signName: String
    let signCategory: TrafficSignCategory
    let explanation: String
    let confidence: Double
    let imageData: Data?

    var confidencePercentage: Int { Int(confidence * 100) }

    var confidenceLabel: String {
        switch confidence {
        case 0.75...: return "High"
        case 0.40...: return "Medium"
        default:      return "Low"
        }
    }
}

enum TrafficSignCategory: String, CaseIterable, Codable {
    case prohibitory   = "Prohibitory"
    case mandatory     = "Mandatory"
    case warning       = "Warning"
    case informational = "Informational"
    case priority      = "Priority"
    case unknown       = "Unknown"
}
