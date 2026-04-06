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
    let severity: Severity
    let questionIds: [Int]

    enum Severity: String, Codable {
        case low
        case medium
        case high
    }

    init(id: UUID = UUID(), categoryName: String, description: String, severity: Severity, questionIds: [Int]) {
        self.id = id
        self.categoryName = categoryName
        self.description = description
        self.severity = severity
        self.questionIds = questionIds
    }
}

struct DiagnosticResult: Identifiable, Codable {
    let id: UUID
    let profileId: UUID
    let analyzedAt: Date
    let snapshotVersion: Int
    let analyzedQuestionIds: [Int]

    var categoryStrengths: [CategoryStrength]
    var knowledgeGaps: [KnowledgeGap]
    var estimatedPassProbability: Double

    init(
        id: UUID = UUID(),
        profileId: UUID,
        analyzedAt: Date = Date(),
        snapshotVersion: Int = 1,
        analyzedQuestionIds: [Int] = [],
        categoryStrengths: [CategoryStrength] = [],
        knowledgeGaps: [KnowledgeGap] = [],
        estimatedPassProbability: Double = 0.0
    ) {
        self.id = id
        self.profileId = profileId
        self.analyzedAt = analyzedAt
        self.snapshotVersion = snapshotVersion
        self.analyzedQuestionIds = analyzedQuestionIds
        self.categoryStrengths = categoryStrengths
        self.knowledgeGaps = knowledgeGaps
        self.estimatedPassProbability = estimatedPassProbability
    }
}