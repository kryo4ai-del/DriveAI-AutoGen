enum InsightType: Codable {
    case lowAccuracyInCategory(category: String)
    case streakEndsToday
    case criticalGapBeforeExam
    case recommendedFocusArea(category: String)
}

extension InsightType {
    var localizedMessage: String {
        switch self {
        case .lowAccuracyInCategory(let cat):
            return NSLocalizedString(
                "insight.low_accuracy",
                comment: "User has low accuracy in category"
            ).replacingOccurrences(of: "{category}", with: cat)
        // ...
        }
    }
}