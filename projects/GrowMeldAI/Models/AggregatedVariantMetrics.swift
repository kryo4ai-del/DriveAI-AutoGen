public struct AggregatedVariantMetrics: Codable {
    // ... existing fields
    
    /// Factory to compute aggregation from raw metrics
    public static func aggregate(
        variant: Variant,
        metrics: [ExperimentMetric]
    ) -> AggregatedVariantMetrics {
        guard !metrics.isEmpty else {
            return AggregatedVariantMetrics(
                variantID: variant.id,
                variantName: variant.name,
                totalInteractions: 0,
                correctAnswerRate: 0,
                averageTimeToAnswer: 0,
                learningVelocity: 0
            )
        }
        
        let correct = metrics.filter { $0.questionAnsweredCorrectly }.count
        let rate = Double(correct) / Double(metrics.count)
        let avgTime = metrics.map { $0.timeToAnswerSeconds }.reduce(0, +) / Double(metrics.count)
        let velocity = Double(metrics.count) / 3600.0 // per hour
        
        return AggregatedVariantMetrics(
            variantID: variant.id,
            variantName: variant.name,
            totalInteractions: metrics.count,
            correctAnswerRate: rate,
            averageTimeToAnswer: avgTime,
            averageEngagementScore: metrics.compactMap { $0.engagementScore }.isEmpty 
                ? nil 
                : metrics.compactMap { $0.engagementScore }.reduce(0, +) / Double(metrics.compactMap { $0.engagementScore }.count),
            learningVelocity: velocity
        )
    }
}