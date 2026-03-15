import Foundation

/// Produces localised, contextual projection messages for a readiness score.
/// Isolated here so `ReadinessScore` remains a pure value type and
/// copy changes do not touch business logic.
enum ReadinessScoreFormatter {

    /// Returns a human-readable projection sentence.
    /// - Parameters:
    ///   - score: The score to describe.
    ///   - daysUntilExam: Days remaining until the user's exam date.
    ///     Values ≤ 0 are treated identically to `nil` (exam passed or no date set).
    static func projectionMessage(
        for score: ReadinessScore,
        daysUntilExam: Int?
    ) -> String {
        guard let days = daysUntilExam, days > 0 else {
            return messageWithoutExamDate(label: score.label)
        }
        return message(label: score.label, daysUntilExam: days)
    }

    // MARK: - Private

    private static func message(
        label: ReadinessScore.ReadinessLabel,
        daysUntilExam days: Int
    ) -> String {
        switch label {
        case .notReady:
            return "Bei diesem Tempo bist du in \(days) Tagen noch nicht bereit — leg jetzt los."
        case .developing:
            return "Du machst Fortschritte. Mit täglichem Üben kannst du in \(days) Tagen bestehen."
        case .almostReady:
            return "Fast da! Noch \(days) Tage — fokussiere dich auf deine schwachen Kategorien."
        case .ready:
            return "Du bist auf Kurs. \(days) Tage bis zur Prüfung — halte den Rhythmus."
        case .examReady:
            return "Prüfungsreif! Noch \(days) Tage zum Feinschliff."
        }
    }

    private static func messageWithoutExamDate(
        label: ReadinessScore.ReadinessLabel
    ) -> String {
        switch label {
        case .notReady:    return "Noch am Anfang — tägliches Üben bringt dich schnell weiter."
        case .developing:  return "Guter Fortschritt. Bleib dran!"
        case .almostReady: return "Fast bereit — konzentriere dich auf schwache Bereiche."
        case .ready:       return "Gut vorbereitet. Übe weiter, um sicher zu bleiben."
        case .examReady:   return "Ausgezeichnet! Du bist prüfungsreif."
        }
    }
}