import Foundation

enum FocusLevel: String, Codable, CaseIterable, Identifiable, Comparable {
    case critical = "critical"
    case important = "important"
    case monitor = "monitor"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .important: return "Important"
        case .monitor: return "Monitor"
        }
    }

    var score: Int {
        switch self {
        case .critical: return 3
        case .important: return 2
        case .monitor: return 1
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.score < rhs.score
    }
}