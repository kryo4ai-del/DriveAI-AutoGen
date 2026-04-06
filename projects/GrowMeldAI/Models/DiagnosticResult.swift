import Foundation

struct CategoryStrength: Identifiable, Codable {
    let id: UUID
    let categoryName: String
    let score: Double
    let totalQuestions: Int
    let correctAnswers: Int

    init(id: UUID = UUID(), categoryName: String, score: Double, totalQuestions: Int, correctAnswers: Int) {
        self.id = id
        self.categoryName = categoryName
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
    }
}

struct KnowledgeGap: Identifiable, Codable {
    let id: UUID
    let categoryName: String
    let description: String
    let recommendedTopics: [String]

    init(id: UUID = UUID(), categoryName: String, description: String, recommendedTopics: [String] = []) {
        self.id = id
        self.categoryName = categoryName
        self.description = description
        self.recommendedTopics = recommendedTopics
    }
}

struct DiagnosticResult: Identifiable, Codable {
    let id: UUID
    let profileId: UUID
    let analyzedAt: Date
    let sourceDataSnapshot: String

    var categoryStrengths: [CategoryStrength]
    var knowledgeGaps: [KnowledgeGap]
    var estimatedPassProbability: Double

    init(
        id: UUID = UUID(),
        profileId: UUID,
        analyzedAt: Date = Date(),
        sourceDataSnapshot: String = "",
        categoryStrengths: [CategoryStrength] = [],
        knowledgeGaps: [KnowledgeGap] = [],
        estimatedPassProbability: Double = 0.0
    ) {
        self.id = id
        self.profileId = profileId
        self.analyzedAt = analyzedAt
        self.sourceDataSnapshot = sourceDataSnapshot
        self.categoryStrengths = categoryStrengths
        self.knowledgeGaps = knowledgeGaps
        self.estimatedPassProbability = estimatedPassProbability
    }
}