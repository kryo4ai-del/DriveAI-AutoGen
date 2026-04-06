import Foundation
struct SpacedRepetitionItem: Identifiable, Equatable {
    let id: String
    let questionId: String
    let categoryId: String
    let categoryName: String
    let questionText: String
    let lastReviewDate: Date?
    let nextReviewDate: Date
    let reviewCount: Int
    let difficulty: QuestionDifficulty
    
    // MARK: - Computed Properties
    
    /// Days until next review (negative = overdue).
    var daysUntilReview: Int {
        let calendar = Calendar.current
        let now = Date()
        
        // Clamp to prevent edge case where time component causes rounding errors
        var nextReviewDateNormalized = nextReviewDate
        nextReviewDateNormalized = calendar.startOfDay(for: nextReviewDateNormalized)
        let nowNormalized = calendar.startOfDay(for: now)
        
        let components = calendar.dateComponents([.day], from: nowNormalized, to: nextReviewDateNormalized)
        return components.day ?? 0
    }
    
    var isOverdue: Bool {
        daysUntilReview < 0
    }
    
    var urgencyLevel: UrgencyLevel {
        let days = daysUntilReview
        switch days {
        case ..<(-7): return .critical
        case -7..<0: return .urgent
        case 0..<3: return .soon
        case 3..<7: return .upcoming
        default: return .scheduled
        }
    }
    
    /// Helper for sorting: returns a comparable tuple (urgency priority, daysUntilReview).
    func urgencyComparator() -> (Int, Int) {
        let urgencyPriority: Int
        switch urgencyLevel {
        case .critical: urgencyPriority = 5
        case .urgent: urgencyPriority = 4
        case .soon: urgencyPriority = 3
        case .upcoming: urgencyPriority = 2
        case .scheduled: urgencyPriority = 1
        }
        
        return (urgencyPriority, daysUntilReview)
    }
}

// MARK: - Codable Conformance
extension SpacedRepetitionItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, questionId, categoryId, categoryName, questionText
        case lastReviewDate, nextReviewDate, reviewCount, difficulty
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.questionId = try container.decode(String.self, forKey: .questionId)
        self.categoryId = try container.decode(String.self, forKey: .categoryId)
        self.categoryName = try container.decode(String.self, forKey: .categoryName)
        self.questionText = try container.decode(String.self, forKey: .questionText)
        self.lastReviewDate = try container.decodeIfPresent(Date.self, forKey: .lastReviewDate)
        self.nextReviewDate = try container.decode(Date.self, forKey: .nextReviewDate)
        self.reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        self.difficulty = try container.decode(QuestionDifficulty.self, forKey: .difficulty)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(questionId, forKey: .questionId)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(categoryName, forKey: .categoryName)
        try container.encode(questionText, forKey: .questionText)
        try container.encodeIfPresent(lastReviewDate, forKey: .lastReviewDate)
        try container.encode(nextReviewDate, forKey: .nextReviewDate)
        try container.encode(reviewCount, forKey: .reviewCount)
        try container.encode(difficulty, forKey: .difficulty)
    }
}