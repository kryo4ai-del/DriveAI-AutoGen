// Single source of truth: move limits to enum
enum FreemiumTier {
    case free, trial, premium
    
    var questionsPerDay: Int {
        switch self {
        case .free: return 10
        case .trial: return 20
        case .premium: return .max
        }
    }
    
    var canUseExamSimulation: Bool {
        self == .premium
    }
}

func isFeatureAvailable(_ feature: FreemiumFeature) -> Bool {
    let tier = currentTier()
    return feature.isAvailableFor(tier)
}