// Models/Performance/PerformanceModels.swift

import Foundation

// MARK: - Configuration
struct PerformanceConfig {
    static let shared = PerformanceConfig()
    
    let passingScore: Int = 43
    let maxScore: Int = 50
    let cacheTimeInterval: TimeInterval = 5 * 60
    let maxRecentAttempts: Int = 20
    let maxRecentExams: Int = 10
    
    var passingPercentage: Double {
        Double(passingScore) / Double(maxScore) * 100
    }
}

// MARK: - QuestionAttempt

// MARK: - ExamAttempt
// Struct ExamAttempt declared in Models/QuestionAttempt.swift

// MARK: - CategoryScore
// Struct CategoryScore declared in Models/QuestionAttempt.swift

// MARK: - PerformanceMetrics
// Struct PerformanceMetrics declared in Models/PerformanceMetrics.swift

// MARK: - CategoryMetric
// Struct CategoryMetric declared in Models/QuestionAttempt.swift

// MARK: - StreakData
// Struct StreakData declared in Models/StreakData.swift

// MARK: - PerformanceState

// MARK: - PerformanceError