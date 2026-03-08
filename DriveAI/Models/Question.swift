import Foundation

struct Question: Identifiable {
    let id: UUID = UUID()
    let questionText: String
    let options: [String]
    let correctAnswer: String
}