struct DriverExamPlan: Codable, Identifiable {
    let readinessScore: Double  // 0.0–1.0, not descriptive
    let recommendedQuestions: [RecommendedQuestion]
    // No accessibility summary
}