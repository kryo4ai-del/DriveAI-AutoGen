enum CheckSeverity: Int, Codable, Comparable, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    
    // For UI labels
    var localizedLabel: String {
        switch self {
        case .low:
            return "Info"
        case .medium:
            return "Hinweis"
        case .high:
            return "Wichtig"
        }
    }
    
    // For VoiceOver accessibility
    var accessibilityDescription: String {
        switch self {
        case .low:
            return NSLocalizedString(
                "severity.low.description",
                value: "Info: Optionale Verbesserung",
                comment: "Low severity explanation"
            )
        case .medium:
            return NSLocalizedString(
                "severity.medium.description",
                value: "Hinweis: Empfohlene Aktion",
                comment: "Medium severity explanation"
            )
        case .high:
            return NSLocalizedString(
                "severity.high.description",
                value: "Wichtig: Sollte zeitnah bearbeitet werden",
                comment: "High severity explanation"
            )
        }
    }
    
    // For visual indicators (non-color dependent)
    var accessibilitySymbol: String {
        switch self {
        case .low:
            return "ℹ︎"  // Info symbol
        case .medium:
            return "⚠"  // Warning symbol
        case .high:
            return "❗"  // Exclamation (high importance)
        }
    }
}