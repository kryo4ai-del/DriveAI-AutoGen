import Foundation

struct QuestionAnswer {
    let questionId: UUID
    let isCorrect: Bool
    let timeTaken: TimeInterval
}

struct QuestionAnalysisSummary: Codable {
    let answeredDate: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let breakdown: [CategoryPerformance]
}

struct CategoryPerformance: Codable {
    let category: String
    let total: Int
    let correct: Int
    let incorrect: Int
}
