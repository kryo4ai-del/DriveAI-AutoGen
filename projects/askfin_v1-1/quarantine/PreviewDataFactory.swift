// Shared PreviewDataFactory
#if DEBUG
struct PreviewDataFactory {
    static func readinessResult(score: Int) -> ExamReadinessResult {
        ExamReadinessResult(
            overallScore: score,
            categoryMetrics: Self.categoryMetrics(averageScore: score),
            recommendations: Self.recommendations(for: score),
            weakCategories: Self.weakCategories(for: score),
            metrics: Self.metrics(),
            generatedAt: .now
        )
    }
    
    static var readinessResult: ExamReadinessResult {
        readinessResult(score: 72)
    }
    
    static var readinessResultInsufficient: ExamReadinessResult {
        readinessResult(score: 25)
    }
    
    // ... other factories
}

// Usage in models
extension ExamReadinessResult {
    static let preview = PreviewDataFactory.readinessResult
    static let previewInsufficient = PreviewDataFactory.readinessResultInsufficient
}
#endif