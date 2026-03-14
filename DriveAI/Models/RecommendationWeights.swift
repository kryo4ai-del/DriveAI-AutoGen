struct RecommendationWeights: Codable {
    let weaknessCoefficient: Double
    let examDaysUrgency: Double
    let difficultyModifier: Double
    
    static let `default` = RecommendationWeights(
        weaknessCoefficient: 2.0,
        examDaysUrgency: 0.5,
        difficultyModifier: 1.2
    )
}

@MainActor