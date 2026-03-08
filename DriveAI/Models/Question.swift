import Foundation

struct Question: Identifiable {
    let id: UUID
    let text: String
    let correctAnswer: String
    let choices: [String]
}

struct Answer {
    let questionId: UUID
    let selectedAnswer: String
    let isCorrect: Bool

    // Computed property for UI convenience
    var displayResult: String {
        return isCorrect ? "Correct: \(selectedAnswer)" : "Incorrect: \(selectedAnswer)"
    }
}