final class RecommendationEngine {
    func generateRecommendations(
        metrics: [PerformanceMetrics],
        maxCount: Int = 5
    ) -> [LearningRecommendation] {
        let weakAreas = metrics.filter { $0.isWeak }.sorted { a, b in
            a.accuracy < b.accuracy // Weakest first
        }
        
        return weakAreas.prefix(maxCount).map { metric in
            LearningRecommendation(
                categoryId: metric.categoryId,
                categoryName: metric.categoryName,
                title: NSLocalizedString(
                    "recommendation.focus",
                    value: "Fokus auf \(metric.categoryName)",
                    comment: ""
                ),
                description: "Du hast \(String(format: "%.0f%%", metric.accuracy))% — strebe \(metric.accuracy + 15)% an",
                priority: recommendationPriority(accuracy: metric.accuracy),
                estimatedMinutes: Int(((85 - metric.accuracy) / 2.5)),
                targetAccuracy: min(metric.accuracy + 15, 85)
            )
        }
    }
    
    private func recommendationPriority(accuracy: Double) -> LearningRecommendation.Priority {
        switch accuracy {
        case 0..<50: return .critical
        case 50..<65: return .high
        case 65..<75: return .medium
        default: return .low
        }
    }
}