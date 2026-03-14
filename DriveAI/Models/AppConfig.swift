// Add to AppConfig.swift
class AppConfig {
    static let current = AppConfig()
    
    var recommendationWeights: RecommendationWeights {
        let defaults = UserDefaults.standard
        return RecommendationWeights(
            weaknessCoefficient: defaults.double(forKey: "rec_weakness") ?? 2.0,
            examDaysUrgency: defaults.double(forKey: "rec_urgency") ?? 0.5,
            difficultyModifier: defaults.double(forKey: "rec_difficulty") ?? 1.2
        )
    }
}

// Usage:
let engine = RecommendationEngineService(
    examDate: examDate,
    weights: AppConfig.current.recommendationWeights
)