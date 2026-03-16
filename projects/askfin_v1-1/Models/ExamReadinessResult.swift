import Foundation

struct ExamReadinessResult {
    let overallScore: Int
    let categoryMetrics: [CategoryMetric]
    let recommendations: [StudyRecommendation]
    let weakCategories: [String]
    let metrics: ReadinessMetrics
    let generatedAt: Date
}
