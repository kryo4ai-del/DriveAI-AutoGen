import Foundation

/// Represents a single episodic memory tied to a learning moment
struct EpisodicalMemory: Identifiable, Codable {
    let id: UUID
    let questionCategoryId: String
    let questionId: String
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let timestamp: Date
    let emotionalTag: EmotionalTag
    let context: String?
    let confidence: Int // 1-5 scale
    
    enum EmotionalTag: String, Codable, CaseIterable {
        case confusion = "Verwirrung"
        case aha = "Aha-Moment"
        case careless = "Flüchtigkeitsfehler"
        case misunderstanding = "Missverständnis"
        case improvement = "Verbesserung"
    }
    
    /// ✅ Allow ID override for updates
    init(
        id: UUID = UUID(),
        questionCategoryId: String,
        questionId: String,
        userAnswer: String,
        correctAnswer: String,
        isCorrect: Bool,
        emotionalTag: EmotionalTag,
        context: String? = nil,
        confidence: Int = 3
    ) {
        self.id = id
        self.questionCategoryId = questionCategoryId
        self.questionId = questionId
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.isCorrect = isCorrect
        self.timestamp = Date()
        self.emotionalTag = emotionalTag
        self.context = context
        self.confidence = min(max(confidence, 1), 5)
    }
}

struct MemoryInsight: Identifiable {
    let id = UUID()
    let categoryId: String
    let categoryName: String
    let totalMemories: Int
    let correctCount: Int
    let successRate: Double
    let recentMemories: [EpisodicalMemory]
    let topMistakePatterns: [MistakePattern]
}

struct MistakePattern: Identifiable {
    let id = UUID()
    let questionId: String
    let occurrenceCount: Int
    let lastOccurrence: Date
}