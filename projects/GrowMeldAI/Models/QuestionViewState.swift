import Foundation

// MARK: - Supporting Types

struct Question: Identifiable, Codable {
    let id: String
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct QuestionProgress: Codable {
    let current: Int
    let total: Int
}

// MARK: - State Definition

enum QuestionViewState {
    case idle
    case loading
    case loaded(question: Question, progress: QuestionProgress)
    case submitting
    case feedback(isCorrect: Bool, explanation: String)
    case error(Error)
}