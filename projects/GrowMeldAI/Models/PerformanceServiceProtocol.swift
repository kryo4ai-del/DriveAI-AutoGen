import Foundation

// MARK: - Service Protocol
protocol PerformanceServiceProtocol: Actor {
    func fetchMetrics() async throws -> [PerformanceMetric]
    func fetchExamReadiness() async throws -> ExamReadinessData
}

// MARK: - Default Implementation
actor PerformanceService: PerformanceServiceProtocol {
    
    // Simulate network delay for development
    private let simulatedDelay: TimeInterval = 0.3
    
    func fetchMetrics() async throws -> [PerformanceMetric] {
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        // TODO: Replace with actual database query
        return [
            PerformanceMetric(
                id: "signs",
                categoryName: "Verkehrszeichen",
                successRate: 0.85,
                totalQuestions: 50,
                correctAnswers: 42,
                lastReviewDate: Date(timeIntervalSinceNow: -86400)
            ),
            PerformanceMetric(
                id: "rules",
                categoryName: "Verkehrsregeln",
                successRate: 0.72,
                totalQuestions: 60,
                correctAnswers: 43,
                lastReviewDate: Date(timeIntervalSinceNow: -172800)
            ),
            PerformanceMetric(
                id: "fines",
                categoryName: "Bußgelder",
                successRate: 0.68,
                totalQuestions: 40,
                correctAnswers: 27,
                lastReviewDate: nil
            )
        ]
    }
    
    func fetchExamReadiness() async throws -> ExamReadinessData {
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        let metrics = try await fetchMetrics()
        let avgSuccessRate = metrics.map { $0.successRate }.reduce(0, +) / Double(metrics.count)
        let completedCount = metrics.filter { $0.lastReviewDate != nil }.count
        
        let readinessLevel: ExamReadinessData.ReadinessLevel = {
            switch avgSuccessRate {
            case 0.9...:
                return .readyForExam
            case 0.8..<0.9:
                return .advanced
            case 0.7..<0.8:
                return .intermediate
            case 0.5..<0.7:
                return .beginner
            default:
                return .notStarted
            }
        }()
        
        return ExamReadinessData(
            daysRemaining: 14,
            overallSuccessRate: avgSuccessRate,
            categoriesCompleted: completedCount,
            totalCategories: metrics.count,
            readinessLevel: readinessLevel
        )
    }
}