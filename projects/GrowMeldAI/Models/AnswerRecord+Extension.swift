import Foundation

// MARK: - Accessibility Extension

extension AnswerRecord {
    var accessibilityAnnouncement: String {
        return isCorrect ?
            NSLocalizedString("Richtig! Die Antwort ist korrekt.", comment: "") :
            NSLocalizedString("Falsch. Die richtige Antwort wird angezeigt.", comment: "")
    }

    var accessibilityHint: String {
        return NSLocalizedString("Wische nach links für Erklärung", comment: "")
    }
}