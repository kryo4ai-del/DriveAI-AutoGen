import Foundation

struct QuestionCategory: Identifiable, Codable {
    let id: UUID
    let name: String
    var questions: [Question] // Updated to use Question model
}