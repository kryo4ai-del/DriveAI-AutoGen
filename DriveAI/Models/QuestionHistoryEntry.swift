import Foundation

struct QuestionHistoryEntry: Identifiable, Codable {
    let id: UUID
    let questionText: String
    let userAnswer: String
    let correctAnswer: String
    let confidenceScore: Double
    let confidenceLabel: String
    let isCorrect: Bool
    let timestamp: Date
    let imageData: Data?   // JPEG-compressed thumbnail, nil for old entries

    init(id: UUID = UUID(),
         questionText: String,
         userAnswer: String,
         correctAnswer: String,
         confidenceScore: Double = 0,
         confidenceLabel: String = "",
         isCorrect: Bool,
         timestamp: Date = Date(),
         imageData: Data? = nil) {
        self.id = id
        self.questionText = questionText
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.confidenceScore = confidenceScore
        self.confidenceLabel = confidenceLabel
        self.isCorrect = isCorrect
        self.timestamp = timestamp
        self.imageData = imageData
    }
}
