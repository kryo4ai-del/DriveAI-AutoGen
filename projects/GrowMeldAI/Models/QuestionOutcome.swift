import Foundation
struct QuestionOutcome {
    let questionId: String
    let categoryId: String
    let isCorrect: Bool
    let timeToAnswer: TimeInterval
    let confidenceLevel: Int  // 1-5, collected in UI later
}

struct RetrievalSchedule {
    let nextReviewDate: Date  // Based on spacing algorithm
    let difficultyLevel: Int  // 1-5
    let reviewCount: Int
}
