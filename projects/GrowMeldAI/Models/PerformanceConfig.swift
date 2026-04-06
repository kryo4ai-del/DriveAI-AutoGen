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
struct ExamAttempt: Identifiable, Codable, Equatable {
    let id: UUID
    let attempts: [QuestionAttempt]
    let startTime: Date
    let endTime: Date
    let totalScore: Int
    let maxScore: Int
    let categoryScores: [UUID: CategoryScore]
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var accuracyPercentage: Double {
        guard maxScore > 0 else { return 0 }
        return Double(totalScore) / Double(maxScore) * 100
    }
    
    var isPassed: Bool {
        totalScore >= PerformanceConfig.shared.passingScore
    }
    
    init(
        attempts: [QuestionAttempt],
        startTime: Date,
        endTime: Date,
        totalScore: Int,
        maxScore: Int,
        categoryScores: [UUID: CategoryScore]
    ) {
        self.id = UUID()
        self.attempts = attempts.map { var a = $0; a.examID = UUID(); return a }
        self.startTime = startTime
        self.endTime = endTime
        self.totalScore = totalScore
        self.maxScore = maxScore
        self.categoryScores = categoryScores
    }
}

// MARK: - CategoryScore
struct CategoryScore: Codable, Equatable {
    let categoryID: UUID
    let categoryName: String
    let correctAnswers: Int
    let totalQuestions: Int
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
}

// MARK: - PerformanceMetrics
struct PerformanceMetrics: Codable, Equatable {
    let totalAttempts: Int
    let totalExams: Int
    let overallAccuracy: Double
    let totalTimeSpent: TimeInterval
    let categoryMetrics: [UUID: CategoryMetric]
    let lastActivityDate: Date?
    
    var averageTimePerQuestion: TimeInterval {
        guard totalAttempts > 0 else { return 0 }
        return totalTimeSpent / Double(totalAttempts)
    }
    
    var weakestCategories: [UUID] {
        categoryMetrics
            .sorted { $0.value.accuracy < $1.value.accuracy }
            .prefix(3)
            .map { $0.key }
    }
}

// MARK: - CategoryMetric
struct CategoryMetric: Codable, Equatable {
    let categoryID: UUID
    let categoryName: String
    let attempts: Int
    let correctAttempts: Int
    let totalTimeSpent: TimeInterval
    
    var accuracy: Double {
        guard attempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(attempts) * 100
    }
    
    var averageTime: TimeInterval {
        guard attempts > 0 else { return 0 }
        return totalTimeSpent / Double(attempts)
    }
}

// MARK: - StreakData
struct StreakData: Codable, Equatable {
    let currentStreak: Int
    let longestStreak: Int
    let lastActivityDate: Date?
    let totalActiveDays: Int
    
    var isStreakActive: Bool {
        guard let lastActivity = lastActivityDate else { return false }
        let daysSinceLastActivity = Calendar.current.dateComponents(
            [.day],
            from: lastActivity,
            to: Date()
        ).day ?? 0
        return daysSinceLastActivity <= 1
    }
}

// MARK: - PerformanceState

// MARK: - PerformanceError