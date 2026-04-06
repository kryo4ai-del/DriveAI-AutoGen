@MainActor
final class FeatureGateManager: ObservableObject {
    @Published var gatingRules: [String: FeatureGate] = [:]
    
    static let shared = FeatureGateManager()
    
    private init() {
        loadGatingRules()
    }
    
    // ✅ Legal MUST define feature classification
    // This is hardcoded placeholder; will be injected from legal review
    private func loadGatingRules() {
        gatingRules = [
            "category.signs": FeatureGate(name: "Verkehrszeichen", requiresPaid: false),
            "category.rightOfWay": FeatureGate(name: "Vorfahrtsregeln", requiresPaid: false),
            "category.fines": FeatureGate(name: "Geldbußgelder", requiresPaid: true), // ← Example premium
            "feature.examSimulation": FeatureGate(name: "Prüfungssimulation", requiresPaid: false, freeLimit: 2),
            "feature.progressTracking": FeatureGate(name: "Fortschrittsanalyse", requiresPaid: true),
        ]
    }
    
    func canAccess(_ feature: String) -> Bool {
        guard let gate = gatingRules[feature] else { return true } // Unknown feature: allow
        
        if !gate.requiresPaid {
            return true // Free feature
        }
        
        return TrialStateManager.shared.isPaid // Paid feature: check subscription
    }
    
    func canAccessWithLimit(_ feature: String) -> (canAccess: Bool, remaining: Int?) {
        guard let gate = gatingRules[feature] else { return (true, nil) }
        
        if TrialStateManager.shared.isPaid {
            return (true, nil) // Unlimited for paid users
        }
        
        if let limit = gate.freeLimit {
            let used = getUserUsageCount(feature)
            let remaining = max(0, limit - used)
            return (remaining > 0, remaining)
        }
        
        return (true, nil)
    }
    
    private func getUserUsageCount(_ feature: String) -> Int {
        // TODO: Implement usage tracking
        return 0
    }
}
