struct LearningGap {
    let id: UUID
    let category: Category
    let gapSeverity: GapSeverity
    let recommendedPracticeCount: Int
    let lastReviewedDate: Date?
    let estimatedMinutesToClose: Int
    
    // NEW: Competence feedback
    let previousAccuracy: Double?  // Last diagnostic result
    let accuracyDelta: Double?     // Improvement since last review
    let severityDelta: GapSeverity? // Did it improve? (critical → moderate)
    
    /// Self-efficacy message: Did I improve?
    var competenceFeedback: String {
        if let delta = accuracyDelta, delta > 0 {
            return "✅ +\(Int(delta * 100))% Improvement seit letzter Diagnose! Du machst echte Fortschritte."
        } else if let previousSev = severityDelta, previousSev > gapSeverity {
            return "✅ Lückeschweregrad verbessert von \(previousSev.label) zu \(gapSeverity.label). Weiter so!"
        } else if accuracyDelta == 0 || accuracyDelta == nil {
            return "🎯 Erste Diagnose für diese Kategorie – lass uns sehen, wo du stehst."
        } else {
            return "📉 Noch nicht verbessert – das ist normal. Fokus auf \(recommendedPracticeCount) Wiederholungen."
        }
    }
}