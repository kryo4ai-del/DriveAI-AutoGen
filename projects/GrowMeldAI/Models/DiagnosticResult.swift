import Foundation

struct CategoryStrength: Identifiable, Codable {
    let id: UUID
    let categoryName: String
    let score: Double
    let totalQuestions: Int
    let correctAnswers: Int
}

struct KnowledgeGap: Identifiable, Codable {
    let id: UUID
    let topicName: String
    let severity: Double
    let recommendedFocus: String
}

struct DiagnosticResult: Identifiable, Codable {
    let id: UUID
    let profileId: UUID
    let analyzedAt: Date
    var categoryStrengths: [CategoryStrength]
    var knowledgeGaps: [KnowledgeGap]
    var estimatedPassProbability: Double
}