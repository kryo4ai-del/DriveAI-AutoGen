import Foundation

extension UserProgress {
    func recordingCorrectAnswer() -> UserProgress {
        var copy = self
        copy.totalQuestionsAnswered += 1
        copy.correctAnswers += 1
        copy.lastReviewedDate = Date()
        return copy
    }

    func recordingIncorrectAnswer() -> UserProgress {
        var copy = self
        copy.totalQuestionsAnswered += 1
        copy.lastReviewedDate = Date()
        return copy
    }
}