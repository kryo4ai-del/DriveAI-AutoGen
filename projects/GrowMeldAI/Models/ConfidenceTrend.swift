import Foundation
enum ConfidenceTrend {
    case improving, stable, declining
    
    var symbol: String {
        switch self {
        case .improving: return "arrow.up"
        case .stable: return "minus"
        case .declining: return "arrow.down"
        }
    }
    
    var label: String {
        switch self {
        case .improving: return NSLocalizedString("trend.improving", comment: "VoiceOver label")
        case .stable: return NSLocalizedString("trend.stable", comment: "VoiceOver label")
        case .declining: return NSLocalizedString("trend.declining", comment: "VoiceOver label")
        }
    }
    
    var accessibilityDescription: String {
        switch self {
        case .improving:
            return NSLocalizedString("trend.a11y.improving", comment: "Your confidence is increasing")
        case .stable:
            return NSLocalizedString("trend.a11y.stable", comment: "Your confidence is stable")
        case .declining:
            return NSLocalizedString("trend.a11y.declining", comment: "Your confidence is declining")
        }
    }
}