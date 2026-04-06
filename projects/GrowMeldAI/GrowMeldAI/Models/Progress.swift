import Foundation

struct Progress: Identifiable, Codable, Equatable {
    var id: String?
    var userID: String
    var questionID: String
    var categoryID: String
    var answered: Bool
    var correct: Bool
    var userAnswer: Int?
    var answeredAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case questionID
        case categoryID
        case answered
        case correct
        case userAnswer
        case answeredAt
    }
}