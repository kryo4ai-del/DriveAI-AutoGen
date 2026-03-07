import Foundation

struct Question: Identifiable {
    let id = UUID()
    let questionText: String
    let correctAnswer: String
    let givenAnswer: String
    let isCorrect: Bool
}