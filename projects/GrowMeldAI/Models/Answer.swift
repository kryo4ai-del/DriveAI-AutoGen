import Foundation

struct QuizAnswer: Identifiable, Codable {
    let id: String
    let text: String
    let explanation: String
}