import SwiftUI

/// How well a learner has mastered a topic.
enum CompetenceLevel: Int, CaseIterable, Codable, Comparable {
    case notStarted = 0
    case weak       = 1
    case shaky      = 2
    case solid      = 3
    case mastered   = 4

    static func < (lhs: CompetenceLevel, rhs: CompetenceLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .notStarted: return "Nicht gestartet"
        case .weak:       return "Schwach"
        case .shaky:      return "Unsicher"
        case .solid:      return "Solide"
        case .mastered:   return "Beherrscht"
        }
    }

    var fillColor: Color {
        switch self {
        case .notStarted: return Color(.systemGray5)
        case .weak:       return Color(.systemRed)
        case .shaky:      return Color(.systemOrange)
        case .solid:      return Color(.systemYellow)
        case .mastered:   return Color(.systemGreen)
        }
    }

    /// Foreground color maintaining ≥4.5:1 contrast against fillColor.
    /// systemYellow requires black; all others use white.
    var contrastingTextColor: Color {
        self == .solid ? .black : .white
    }

    var next: CompetenceLevel? {
        CompetenceLevel(rawValue: rawValue + 1)
    }

    /// Requires totalAnswers so .notStarted is handled here, not at every call site.
    static func from(weightedAccuracy: Double, totalAnswers: Int) -> CompetenceLevel {
        guard totalAnswers > 0 else { return .notStarted }
        switch weightedAccuracy {
        case ..<Threshold.weak:  return .weak
        case ..<Threshold.shaky: return .shaky
        case ..<Threshold.solid: return .solid
        default:                 return .mastered
        }
    }
}