import Foundation

struct RecommendedQuestion: Codable, Identifiable {
    let id: UUID
    let question: String

    init(id: UUID = UUID(), question: String) {
        self.id = id
        self.question = question
    }
}

struct DriverExamPlan: Codable, Identifiable {
    let id: UUID
    let readinessScore: Double  // 0.0–1.0, not descriptive
    let recommendedQuestions: [RecommendedQuestion]
    // No accessibility summary

    init(id: UUID = UUID(), readinessScore: Double, recommendedQuestions: [RecommendedQuestion]) {
        self.id = id
        self.readinessScore = readinessScore
        self.recommendedQuestions = recommendedQuestions
    }
}