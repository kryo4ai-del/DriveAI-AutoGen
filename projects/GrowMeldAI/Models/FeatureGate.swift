// Services/FeatureGateService.swift

struct FeatureGate: Identifiable {
    let id: String
    let requiredTier: SubscriptionTier
    let fallbackBehavior: FeatureFallback
    let analyticsEvent: String
}

enum FeatureFallback {
    case showPaywall
    case limitedTrial(questionsAllowed: Int)
    case hidden
}

@MainActor
final class FeatureGateService {
    static let shared = FeatureGateService()
    
    private let gates: [String: FeatureGate] = [
        "exam_simulation": FeatureGate(
            id: "exam_simulation",
            requiredTier: .premium,
            fallbackBehavior: .showPaywall,
            analyticsEvent: "exam_gate_hit"
        ),
        "offline_sync": FeatureGate(
            id: "offline_sync",
            requiredTier: .premiumPlus,
            fallbackBehavior: .showPaywall,
            analyticsEvent: "offline_gate_hit"
        ),
        "practice_questions": FeatureGate(
            id: "practice_questions",
            requiredTier: .free, // No gate for free users
            fallbackBehavior: .hidden,
            analyticsEvent: nil
        ),
        "ad_removal": FeatureGate(
            id: "ad_removal",
            requiredTier: .premiumPlus,
            fallbackBehavior: .hidden,
            analyticsEvent: nil
        )
    ]
    
    func canAccess(_ featureID: String, for tier: SubscriptionTier) -> Bool {
        guard let gate = gates[featureID] else { return true } // Unknown gate = allow
        return tier.rawValue >= gate.requiredTier.rawValue
    }
    
    func fallbackBehavior(for featureID: String, tier: SubscriptionTier) -> FeatureFallback? {
        guard let gate = gates[featureID], !canAccess(featureID, for: tier) else {
            return nil // No fallback needed; access granted
        }
        return gate.fallbackBehavior
    }
    
    func shouldShowFeature(_ featureID: String, for tier: SubscriptionTier) -> Bool {
        guard let gate = gates[featureID] else { return true }
        
        if canAccess(featureID, for: tier) { return true }
        
        // Hidden gates are not shown even if access denied
        if case .hidden = gate.fallbackBehavior { return false }
        
        return true
    }
}