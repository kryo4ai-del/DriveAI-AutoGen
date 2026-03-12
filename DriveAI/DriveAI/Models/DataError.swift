import Foundation

enum DataError: Error {
    case questionLoadingFailed
    case parsingError(String)
    // More cases can be added as needed
}

class LocalDataService {
    static let shared = LocalDataService()

    func loadQuizQuestions() throws -> [QuizQuestion] {
        guard let questions = loadFromSource() else {
            throw DataError.questionLoadingFailed // Uniform error handling for data loading
        }
        return questions
    }
    
    private func loadFromSource() -> [QuizQuestion]? {
        return [
            QuizQuestion(id: UUID(), question: "What does this sign mean?", options: ["Stop", "Yield", "Go"], correctAnswerIndex: 0),
            QuizQuestion(id: UUID(), question: "What should you do when this light is on?", options: ["Speed up", "Slow down", "Stop"], correctAnswerIndex: 2)
        ]
    }
}