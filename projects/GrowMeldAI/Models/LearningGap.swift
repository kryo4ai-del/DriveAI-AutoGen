import Foundation

struct LearningGap {
    let id: UUID
    let category: String
    let gapSeverity: GapSeverity
    let recommendedPracticeCount: Int
    let lastReviewedDate: Date?
    let estimatedMinutesToClose: Int

    let previousAccuracy: Double?
    let accuracyDelta: Double?
    let severityDelta: GapSeverity?

    var competenceFeedback: String {
        if let delta = accuracyDelta, delta > 0 {
            return "✅ +\(Int(delta * 100))% Improvement seit letzter Diagnose! Du machst echte Fortschritte."
        } else if let previousSev = severityDelta, previousSev.rawValue > gapSeverity.rawValue {
            return "✅ Lückeschweregrad verbessert von \(previousSev.label) zu \(gapSeverity.label). Weiter so!"
        } else if accuracyDelta == nil {
            return "🎯 Erste Diagnose für diese Kategorie – lass uns sehen, wo du stehst."
        } else {
            return "📉 Noch nicht verbessert – das ist normal. Fokus auf \(recommendedPracticeCount) Wiederholungen."
        }
    }
}

enum GapSeverity: Int, Comparable {
    case low = 0
    case moderate = 1
    case high = 2
    case critical = 3

    var label: String {
        switch self {
        case .low: return "Niedrig"
        case .moderate: return "Moderat"
        case .high: return "Hoch"
        case .critical: return "Kritisch"
        }
    }

    static func < (lhs: GapSeverity, rhs: GapSeverity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}