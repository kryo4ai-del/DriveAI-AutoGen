// Models/Performance/PerformanceModels.swift

import Foundation

// MARK: - QuestionAttempt
/// Represents a single question answered by the user
struct QuestionAttempt: Identifiable, Codable {
    let id: UUID
    let questionID: UUID
    let categoryID: UUID
    let selectedAnswerIndex: Int
    let correctAnswerIndex: Int
    let timeSpentSeconds: TimeInterval
    let timestamp: Date
    let isCorrect: Bool
    
    init(
        questionID: UUID,
        categoryID: UUID,
        selectedAnswerIndex: Int,
        correctAnswerIndex: Int,
        timeSpentSeconds: TimeInterval,
        isCorrect: Bool
    ) {
        self.id = UUID()
        self.questionID = questionID
        self.categoryID = categoryID
        self.selectedAnswerIndex = selectedAnswerIndex
        self.correctAnswerIndex = correctAnswerIndex
        self.timeSpentSeconds = timeSpentSeconds
        self.timestamp = Date()
        self.isCorrect = isCorrect
    }
    
    enum CodingKeys: String, CodingKey {
        case id, questionID, categoryID, selectedAnswerIndex, correctAnswerIndex, timeSpentSeconds, timestamp, isCorrect
    }
}

// MARK: - ExamAttempt
/// Represents a complete 30-question exam session
struct ExamAttempt: Identifiable, Codable {
    let id: UUID
    let attempts: [QuestionAttempt]
    let startTime: Date
    let endTime: Date
    let totalScore: Int // out of 50 (some questions worth 2 points)
    let maxScore: Int
    let isPassed: Bool
    let categoryScores: [UUID: CategoryScore] // category ID -> score breakdown
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var accuracyPercentage: Double {
        guard maxScore > 0 else { return 0 }
        return Double(totalScore) / Double(maxScore) * 100
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
        self.attempts = attempts
        self.startTime = startTime
        self.endTime = endTime
        self.totalScore = totalScore
        self.maxScore = maxScore
        self.categoryScores = categoryScores
        // German DACH standard: 43/50 = 86% required
        self.isPassed = totalScore >= 43
    }
    
    enum CodingKeys: String, CodingKey {
        case id, attempts, startTime, endTime, totalScore, maxScore, isPassed, categoryScores
    }
}

// MARK: - CategoryScore
/// Performance breakdown per category
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
/// Aggregated performance statistics
struct PerformanceMetrics: Codable, Equatable {
    let totalAttempts: Int
    let totalExams: Int
    let overallAccuracy: Double // percentage 0-100
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
/// Per-category performance data
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
/// User's learning streak tracking
struct StreakData: Codable, Equatable {
    let currentStreak: Int // consecutive days with activity
    let longestStreak: Int
    let lastActivityDate: Date?
    let totalActivedays: Int
    
    var isStreakActive: Bool {
        guard let lastActivity = lastActivityDate else { return false }
        let daysSinceLastActivity = Calendar.current.dateComponents([.day], from: lastActivity, to: Date()).day ?? 0
        return daysSinceLastActivity <= 1
    }
}

// MARK: - PerformanceState
/// Single source of truth for performance data

// MARK: - PerformanceError