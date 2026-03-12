import Foundation

class LocalDataService {
    static let shared = LocalDataService()

    func fetchQuestions() -> [QuestionModel] {
        // Load questions from JSON or local database
        return [] // Placeholder for actual fetching logic
    }

    func loadQuestions() -> [Question] {
        // Placeholder for loading Question objects
        return []
    }

    func loadQuizQuestions() throws -> [QuizQuestion] {
        return [
            QuizQuestion(id: UUID(), question: "What does this sign mean?", options: ["Stop", "Yield", "Go"], correctAnswerIndex: 0),
            QuizQuestion(id: UUID(), question: "What should you do when this light is on?", options: ["Speed up", "Slow down", "Stop"], correctAnswerIndex: 2)
        ]
    }
}
