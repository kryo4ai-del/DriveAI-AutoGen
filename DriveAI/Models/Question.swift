import Foundation

struct Question: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let options: [String]
    let correctAnswer: String
}