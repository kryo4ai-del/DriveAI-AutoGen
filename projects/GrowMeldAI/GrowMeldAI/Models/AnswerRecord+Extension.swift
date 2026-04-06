import Foundation

// MARK: - AnswerRecord Model

struct AnswerRecord {
    let isCorrect: Bool
    let questionID: String
    let selectedAnswer: String
    let correctAnswer: String
    let timestamp: Date

    init(
        isCorrect: Bool,
        questionID: String = "",
        selectedAnswer: String = "",
        correctAnswer: String = "",
        timestamp: Date = Date()
    ) {
        self.isCorrect = isCorrect
        self.questionID = questionID
        self.selectedAnswer = selectedAnswer
        self.correctAnswer = correctAnswer
        self.timestamp = timestamp
    }
}

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