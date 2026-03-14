// ✅ FIXED: Make configurable

class RecommendationEngineService {
    static var defaultWeights: RecommendationWeights {
        // Load from configuration file or remote config
        RecommendationWeights(
            weaknessCoefficient: UserDefaults.standard.double(
                forKey: "recomm_weakness_coeff"
            ) ?? 2.0,
            examDaysUrgency: 0.5,
            difficultyModifier: 1.2
        )
    }
}

// Add to AppDelegate or startup:
func configureDefaultWeights() {
    let config = RemoteConfig.remoteConfig()
    UserDefaults.standard.set(
        config.configValue(forKey: "weakness_coefficient").doubleValue,
        forKey: "recomm_weakness_coeff"
    )
}