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
    let category: QuestionCategory
    let categoryConfidence: Double

    init(id: UUID = UUID(),
         questionText: String,
         userAnswer: String,
         correctAnswer: String,
         confidenceScore: Double = 0,
         confidenceLabel: String = "",
         isCorrect: Bool,
         timestamp: Date = Date(),
         imageData: Data? = nil,
         category: QuestionCategory = .general,
         categoryConfidence: Double = 0) {
        self.id = id
        self.questionText = questionText
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.confidenceScore = confidenceScore
        self.confidenceLabel = confidenceLabel
        self.isCorrect = isCorrect
        self.timestamp = timestamp
        self.imageData = imageData
        self.category = category
        self.categoryConfidence = categoryConfidence
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(UUID.self,   forKey: .id)
        questionText       = try c.decode(String.self, forKey: .questionText)
        userAnswer         = try c.decode(String.self, forKey: .userAnswer)
        correctAnswer      = try c.decode(String.self, forKey: .correctAnswer)
        confidenceScore    = try c.decodeIfPresent(Double.self,  forKey: .confidenceScore)  ?? 0
        confidenceLabel    = try c.decodeIfPresent(String.self,  forKey: .confidenceLabel)  ?? ""
        isCorrect          = try c.decode(Bool.self,   forKey: .isCorrect)
        timestamp          = try c.decode(Date.self,   forKey: .timestamp)
        imageData          = try c.decodeIfPresent(Data.self,    forKey: .imageData)
        category           = try c.decodeIfPresent(QuestionCategory.self, forKey: .category) ?? .general
        categoryConfidence = try c.decodeIfPresent(Double.self,  forKey: .categoryConfidence) ?? 0
    }
}
