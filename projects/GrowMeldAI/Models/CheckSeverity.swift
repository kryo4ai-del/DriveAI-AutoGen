import Foundation

enum CheckSeverity: Int, Codable, Comparable, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3

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

    var accessibilityDescription: String {
        switch self {
        case .low:
            return NSLocalizedString(
                "severity.low.description",
                bundle: .main,
                value: "Info: Optionale Verbesserung",
                comment: "Low severity explanation"
            )
        case .medium:
            return NSLocalizedString(
                "severity.medium.description",
                bundle: .main,
                value: "Hinweis: Empfohlene Aktion",
                comment: "Medium severity explanation"
            )
        case .high:
            return NSLocalizedString(
                "severity.high.description",
                bundle: .main,
                value: "Wichtig: Sollte zeitnah bearbeitet werden",
                comment: "High severity explanation"
            )
        }
    }

    var accessibilitySymbol: String {
        switch self {
        case .low:
            return "ℹ︎"
        case .medium:
            return "⚠"
        case .high:
            return "❗"
        }
    }

    static func < (lhs: CheckSeverity, rhs: CheckSeverity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}