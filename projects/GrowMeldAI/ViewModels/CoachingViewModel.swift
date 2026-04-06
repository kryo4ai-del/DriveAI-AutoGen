class CoachingViewModel: ObservableObject {
    // ... existing code ...
    
    // MARK: - Accessibility Support
    
    /// Generates accessibility description for a recommendation
    func accessibilityDescription(for recommendation: CoachingRecommendation) -> String {
        """
        \(recommendation.categoryName). \
        Aktuelle Punktzahl: \(Int(recommendation.currentScore)) von 10. \
        \(recommendation.rootCause). \
        Empfehlung: \(recommendation.prescription). \
        Geschätzte Zeit: \(recommendation.estimatedImprovementMinutes) Minuten.
        """
    }
    
    /// Generates accessibility hint for insight
    func accessibilityHint(for insight: MemoryInsight) -> String {
        """
        Nächste Wiederholung \(insight.nextReviewLabel). \
        Vertrauensniveau: \(Int(insight.currentConfidence))%. \
        Trend: \(insight.confidenceTrend.label).
        """
    }
    
    /// Custom action for VoiceOver: "Practice Now"
    func practiceNowAction(categoryId: String) {
        // Navigate to quiz with category pre-filter
        print("🎓 Practice Now: \(categoryId)")
    }
    
    /// Custom action for VoiceOver: "Increase Confidence"
    func adjustConfidence(for recommendationId: UUID, increase: Bool) {
        guard let index = recommendations.firstIndex(where: { $0.id == recommendationId }) else { return }
        let currentConfidence = recommendations[index].confidencePercentage
        let newConfidence = increase ? min(currentConfidence + 10, 100) : max(currentConfidence - 10, 0)
        
        // Update and persist
        let updated = CoachingRecommendation(
            id: recommendations[index].id,
            categoryId: recommendations[index].categoryId,
            categoryName: recommendations[index].categoryName,
            currentScore: recommendations[index].currentScore,
            rootCause: recommendations[index].rootCause,
            prescription: recommendations[index].prescription,
            urgencyLevel: recommendations[index].urgencyLevel,
            confidencePercentage: newConfidence,
            nextReviewDate: recommendations[index].nextReviewDate,
            estimatedImprovementMinutes: recommendations[index].estimatedImprovementMinutes
        )
        recommendations[index] = updated
    }
}