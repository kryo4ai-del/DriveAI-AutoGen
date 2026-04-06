import Foundation

struct MisconceptionModel: Codable, Identifiable, Equatable {
    let id: UUID
    let questionId: String
    let categoryId: String
    let misconceptionType: MisconceptionType
    var frequency: Int
    var lastOccurrence: Date
    let suggestedExplanation: String

    init(id: UUID = UUID(),
         questionId: String,
         categoryId: String,
         misconceptionType: MisconceptionType,
         suggestedExplanation: String) {
        self.id = id
        self.questionId = questionId
        self.categoryId = categoryId
        self.misconceptionType = misconceptionType
        self.frequency = 1
        self.lastOccurrence = Date()
        self.suggestedExplanation = suggestedExplanation
    }
}

typealias Misconception = MisconceptionModel

enum MisconceptionType: String, Codable {
    case rightOfWay
    case speedLimit
    case trafficSigns
    case parking
    case generalRules
}