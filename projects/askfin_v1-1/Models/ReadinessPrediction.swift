import Foundation
import SwiftUI

struct ReadinessPrediction: Identifiable, Codable {
    let id: UUID
    let passProbability: Double         // 0-1
    let confidenceLevel: ConfidenceLevel
    let recommendation: String
    let predictedAt: Date
    let factors: [PredictionFactor]
    
    enum ConfidenceLevel: String, Codable {
        case veryHigh
        case high
        case moderate
        case low
        
        var displayText: String {
            switch self {
            case .veryHigh:
                return NSLocalizedString("Very High Confidence", comment: "")
            case .high:
                return NSLocalizedString("High Confidence", comment: "")
            case .moderate:
                return NSLocalizedString("Moderate Confidence", comment: "")
            case .low:
                return NSLocalizedString("Low Confidence", comment: "")
            }
        }
        
        var accessibilityLabel: String {
            displayText + " in prediction"
        }
    }
    
    var passPercentage: Int {
        Int(passProbability * 100)
    }
}

struct PredictionFactor: Codable {
    let name: String
    let impact: Double              // -1.0 to 1.0
    let description: String
    
    var impactPercentage: Int {
        Int(abs(impact) * 100)
    }
    
    var direction: String {
        impact >= 0 ? "positive" : "negative"
    }
}