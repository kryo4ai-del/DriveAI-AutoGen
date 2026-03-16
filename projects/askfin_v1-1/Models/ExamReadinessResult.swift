import Foundation

struct ExamReadinessResult {
    let overallScore: Int
    let categoryMetrics: [CategoryMetric]
    let recommendations: [ReadinessRecommendation]
    let weakCategories: [String]
    let metrics: ReadinessMetrics
    let generatedAt: Date
}
