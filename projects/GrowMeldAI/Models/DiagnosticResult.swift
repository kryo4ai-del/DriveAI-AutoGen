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
    let severity: GapSeverity

    enum GapSeverity: String, Codable {
        case low
        case medium
        case high
    }

    init(id: UUID = UUID(), categoryName: String, description: String, severity: GapSeverity) {
        self.id = id
        self.categoryName = categoryName
        self.description = description
        self.severity = severity
    }
}

struct DiagnosticResult: Identifiable, Codable {
    let id: UUID
    let profileId: UUID
    let analyzedAt: Date
    let questionsSnapshot: [String]
    let answersSnapshot: [String: Bool]

    var categoryStrengths: [CategoryStrength]
    var knowledgeGaps: [KnowledgeGap]
    var estimatedPassProbability: Double

    init(
        id: UUID = UUID(),
        profileId: UUID,
        analyzedAt: Date = Date(),
        questionsSnapshot: [String] = [],
        answersSnapshot: [String: Bool] = [:],
        categoryStrengths: [CategoryStrength] = [],
        knowledgeGaps: [KnowledgeGap] = [],
        estimatedPassProbability: Double = 0.0
    ) {
        self.id = id
        self.profileId = profileId
        self.analyzedAt = analyzedAt
        self.questionsSnapshot = questionsSnapshot
        self.answersSnapshot = answersSnapshot
        self.categoryStrengths = categoryStrengths
        self.knowledgeGaps = knowledgeGaps
        self.estimatedPassProbability = estimatedPassProbability
    }
}