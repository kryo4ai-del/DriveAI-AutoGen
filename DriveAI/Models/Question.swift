import Foundation

struct Question: Identifiable, Decodable {
    var id: UUID
    let category: String
    let text: String
    let choices: [String]
    let correctAnswer: String
    
    // Initializer allows for optional external IDs.
    init(id: UUID = UUID(), category: String, text: String, choices: [String], correctAnswer: String) {
        self.id = id
        self.category = category
        self.text = text
        self.choices = choices
        self.correctAnswer = correctAnswer
    }
}