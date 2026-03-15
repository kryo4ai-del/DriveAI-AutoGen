import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let text: String
    let options: [String]
    let correctAnswer: String
    let difficulty: Difficulty
    let explanation: String
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy, medium, hard
    }
}