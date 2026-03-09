import Foundation

struct QuestionCategory: Identifiable, Codable {
    let id: UUID
    let name: String
    let questionCount: Int
}