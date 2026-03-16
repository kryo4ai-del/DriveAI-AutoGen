import Foundation

struct CategoryResult: Identifiable, Codable, Sendable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let questionsAsked: Int
    let correctAnswers: Int
    let difficulty: DifficultyBreakdown

    var accuracy: Double {
        guard questionsAsked > 0 else { return 0 }
        return (Double(correctAnswers) / Double(questionsAsked)) * 100
    }

    var needsImprovement: Bool {
        accuracy < 70
    }

    init(
        id: UUID = UUID(),
        categoryId: String = "",
        categoryName: String = "",
        questionsAsked: Int = 0,
        correctAnswers: Int = 0,
        difficulty: DifficultyBreakdown = DifficultyBreakdown(
            easy: .init(asked: 0, correct: 0),
            medium: .init(asked: 0, correct: 0),
            hard: .init(asked: 0, correct: 0)
        )
    ) {
        self.id = id
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.questionsAsked = questionsAsked
        self.correctAnswers = correctAnswers
        self.difficulty = difficulty
    }
}