import Foundation

struct LearningGap {
    let id: UUID
    let category: LearningCategory
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
        } else if let previousSev = severityDelta, previousSev > gapSeverity {
            return "✅ Lückeschweregrad verbessert von \(previousSev.label) zu \(gapSeverity.label). Weiter so!"
        } else if accuracyDelta == nil || accuracyDelta == 0 {
            return "🎯 Erste Diagnose für diese Kategorie – lass uns sehen, wo du stehst."
        } else {
            return "📉 Noch nicht verbessert – das ist normal. Fokus auf \(recommendedPracticeCount) Wiederholungen."
        }
    }
}

enum LearningCategory: String, Codable {
    case theory = "theory"
    case practical = "practical"
    case signs = "signs"
    case rules = "rules"
    case safety = "safety"
    case other = "other"
}

enum GapSeverity: Int, Codable, Comparable {
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

extension LearningGap {
    var daysSinceReview: Int? {
        guard let lastReviewedDate = lastReviewedDate else { return nil }
        let components = Calendar.current.dateComponents([.day], from: lastReviewedDate, to: Date())
        return components.day
    }

    var daysUntilNextReview: Int {
        switch gapSeverity {
        case .critical: return 1
        case .high: return 2
        case .moderate: return 4
        case .low: return 7
        }
    }
}