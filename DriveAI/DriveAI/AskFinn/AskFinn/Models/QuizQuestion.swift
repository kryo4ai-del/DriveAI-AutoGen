import Foundation

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    
    // Checks whether the correct answer index is valid
    var isValid: Bool {
        return correctAnswerIndex >= 0 && correctAnswerIndex < options.count
    }
}