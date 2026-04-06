import Foundation

final class MockProgressService: @unchecked Sendable {
    var studySessionsCompleted: Int = 0
    var totalQuestionsAnswered: Int = 0
    var correctAnswersCount: Int = 0
    var currentStreak: Int = 0

    func recordAnswer(questionId: String, isCorrect: Bool) {
        totalQuestionsAnswered += 1
        if isCorrect {
            correctAnswersCount += 1
        }
    }

    func recordSessionCompleted() {
        studySessionsCompleted += 1
    }

    func resetProgress() {
        studySessionsCompleted = 0
        totalQuestionsAnswered = 0
        correctAnswersCount = 0
        currentStreak = 0
    }

    func accuracyRate() -> Double {
        guard totalQuestionsAnswered > 0 else { return 0.0 }
        return Double(correctAnswersCount) / Double(totalQuestionsAnswered)
    }
}