// DriveAI/Services/Localization/LocalizationService.swift
import Foundation

protocol LocalizationServiceProtocol {
    func string(for key: String, arguments: [CVarArg]?) -> String
}

enum L10nKeys {
    enum Quiz {
        static let answerCorrect = "quiz.answer.correct"
        static let answerIncorrect = "quiz.answer.incorrect"
        static let explanation = "quiz.explanation"
        static let nextButton = "quiz.button.next"
        static let prevButton = "quiz.button.prev"
        static let submitButton = "quiz.button.submit"
        static let feedbackCorrect = "quiz.feedback.correct"
        static let feedbackIncorrect = "quiz.feedback.incorrect"
    }

    enum Exam {
        static let timeWarning5min = "exam.warning.5min"
        static let timeRemaining = "exam.time.remaining"
        static let resultTitle = "exam.result.title"
        static let resultPerfect = "exam.result.perfect"
        static let resultGreat = "exam.result.great"
        static let resultGood = "exam.result.good"
        static let resultRetry = "exam.result.retry"
        static let resultContinue = "exam.result.continue"
        static let resultScore = "exam.result.score"
        static let resultTime = "exam.result.time"
        static let resultTimeLeft = "exam.result.timeLeft"
    }

    enum Common {
        static let loading = "common.loading"
        static let errorTitle = "common.error.title"
        static let errorRetry = "common.error.retry"
        static let cancel = "common.cancel"
    }
}