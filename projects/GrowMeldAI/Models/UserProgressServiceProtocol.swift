import Foundation
import Combine

protocol UserProgressServiceProtocol {
    func loadProgress() -> GrowMeldUserProgress
    func saveProgress(_ progress: GrowMeldUserProgress)
    func updateQuestionAnswered(correct: Bool, category: String)
    func updateExamSimulationResult(_ result: GrowMeldUserProgress.ExamSimulationResult)
    func resetProgress()
}

struct GrowMeldUserProgress: Codable {
    var totalQuestionsAnswered: Int
    var correctAnswers: Int
    var categoryProgress: [String: CategoryProgress]
    var examSimulationResults: [ExamSimulationResult]
    var lastUpdated: Date

    init(
        totalQuestionsAnswered: Int = 0,
        correctAnswers: Int = 0,
        categoryProgress: [String: CategoryProgress] = [:],
        examSimulationResults: [ExamSimulationResult] = [],
        lastUpdated: Date = Date()
    ) {
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.correctAnswers = correctAnswers
        self.categoryProgress = categoryProgress
        self.examSimulationResults = examSimulationResults
        self.lastUpdated = lastUpdated
    }

    struct CategoryProgress: Codable {
        var answered: Int
        var correct: Int

        init(answered: Int = 0, correct: Int = 0) {
            self.answered = answered
            self.correct = correct
        }
    }

    struct ExamSimulationResult: Codable, Identifiable {
        var id: String
        var date: Date
        var score: Double
        var passed: Bool
        var totalQuestions: Int
        var correctAnswers: Int

        init(
            id: String = UUID().uuidString,
            date: Date = Date(),
            score: Double,
            passed: Bool,
            totalQuestions: Int,
            correctAnswers: Int
        ) {
            self.id = id
            self.date = date
            self.score = score
            self.passed = passed
            self.totalQuestions = totalQuestions
            self.correctAnswers = correctAnswers
        }
    }
}