import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    let quizId: UUID
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
    let difficulty: Difficulty
    let explanation: String
    
    var correctAnswer: String { options[correctAnswerIndex] }
}

struct UserAnswer: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    let selectedIndex: Int
    let isCorrect: Bool
    let timeSpentSeconds: TimeInterval
}