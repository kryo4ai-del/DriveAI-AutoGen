import Foundation

struct ExamReadinessReport: Codable, Equatable {
    let id: String
    let overallScore: Int
    let categoryBreakdown: [CategoryReadiness]
    let generatedAt: Date
    
    var overallLevel: ReadinessLevel {
        ReadinessLevel.from(percentage: overallScore)
    }
    
    var weakestCategories: [CategoryReadiness] {
        categoryBreakdown.sorted { $0.percentage < $1.percentage }
    }
    
    var strongestCategories: [CategoryReadiness] {
        categoryBreakdown.sorted { $0.percentage > $1.percentage }
    }
    
    init(
        overallScore: Int,
        categoryBreakdown: [CategoryReadiness],
        generatedAt: Date = Date()
    ) {
        self.id = UUID().uuidString
        self.overallScore = max(0, min(overallScore, 100))
        self.categoryBreakdown = categoryBreakdown
        self.generatedAt = generatedAt
    }
    
    static func == (lhs: ExamReadinessReport, rhs: ExamReadinessReport) -> Bool {
        lhs.overallScore == rhs.overallScore &&
        lhs.categoryBreakdown == rhs.categoryBreakdown &&
        lhs.generatedAt.timeIntervalSince1970 == rhs.generatedAt.timeIntervalSince1970
    }
}