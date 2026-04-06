extension ConfidenceLevel {
    var accessibilityLabel: String {
        switch self {
        case .veryLow:
            return NSLocalizedString("confidence.very_low.label", 
                value: "Very low confidence", comment: "Confidence level")
        case .low:
            return NSLocalizedString("confidence.low.label", 
                value: "Low confidence", comment: "Confidence level")
        case .moderate:
            return NSLocalizedString("confidence.moderate.label", 
                value: "Moderate confidence", comment: "Confidence level")
        case .high:
            return NSLocalizedString("confidence.high.label", 
                value: "High confidence", comment: "Confidence level")
        case .veryHigh:
            return NSLocalizedString("confidence.very_high.label", 
                value: "Very high confidence", comment: "Confidence level")
        }
    }
    
    var accessibilityHint: String {
        switch self {
        case .veryLow:
            return NSLocalizedString("confidence.very_low.hint", 
                value: "You may want to review more questions", comment: "Hint")
        case .veryHigh:
            return NSLocalizedString("confidence.very_high.hint", 
                value: "You're well-prepared for your exam", comment: "Hint")
        default:
            return ""
        }
    }
}