// Services/Analytics/AnalyticsEvent.swift
enum AnalyticsEvent: Sendable {
    case questionAnswered(
        questionID: String,
        categoryID: String,
        isCorrect: Bool,
        timeSpent: Int,
        difficulty: DifficultyLevel
    )
    
    // ✅ Localized event descriptions for debug/accessibility purposes
    var localizedDescription: String {
        switch self {
        case .questionAnswered(_, let cID, let correct, _, _):
            let outcome = correct ? NSLocalizedString("korrekt", comment: "correct answer") : NSLocalizedString("falsch", comment: "incorrect answer")
            return NSLocalizedString("Frage beantwortet: \(outcome)", comment: "accessibility description for question answered")
        case .examSimulationCompleted(let score, let maxScore, let pass, _, _):
            return NSLocalizedString("Prüfung abgeschlossen: \(score)/\(maxScore), \(pass.rawValue)", comment: "exam completion announcement")
        // ... all other cases
        default:
            return ""
        }
    }
}

#if DEBUG
@MainActor
func logEvent(_ event: AnalyticsEvent) async {
    print("📊 Analytics (Accessible): \(event.localizedDescription)")  // ✅ German output
}
#endif