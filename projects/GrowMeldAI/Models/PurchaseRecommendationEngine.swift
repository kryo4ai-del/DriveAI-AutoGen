// ✅ CORRECT
class PurchaseRecommendationEngine {
    func generateRecommendation(
        userProgress: ExamProgress,
        unlockedFeatures: Set<String>,
        availableFeatures: [UnlockableFeature]
    ) -> RecommendationResult? {
        guard userProgress.totalAttempts >= 3 else { return nil }
        
        let masteryLevel = userProgress.percentage
        
        if masteryLevel >= 0.80, !unlockedFeatures.contains("detailed_stats") {
            return RecommendationResult(
                feature: availableFeatures.first { $0.featureKey == "detailed_stats" },
                confidence: 0.95,
                rationale: "Du hast 80% richtig – Premium-Statistiken zeigen deine Stärken"
            )
        }
        return nil
    }
}

// In ViewModel:
let recommendation = recommendationEngine.generateRecommendation(
    userProgress: examProgress,
    unlockedFeatures: userState.unlockedFeatures,
    availableFeatures: availableFeatures
)