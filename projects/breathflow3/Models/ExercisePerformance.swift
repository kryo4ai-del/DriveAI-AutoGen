// Models/ExercisePerformance.swift
import Foundation

struct ExercisePerformance: Codable, Sendable, Equatable {
    let exerciseId: UUID
    let completionCount: Int
    let bestScore: Double        // 0-100
    let averageScore: Double     // 0-100
    let lastAttemptDate: Date?
    let totalTimeSpent: TimeInterval
    let createdAt: Date
    let updatedAt: Date

    // THROWING INITIALIZER - Validates all inputs
    init(
        exerciseId: UUID,
        completionCount: Int,
        bestScore: Double,
        averageScore: Double,
        lastAttemptDate: Date? = nil,
        totalTimeSpent: TimeInterval = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) throws {
        guard completionCount >= 0 else {
            throw ExerciseSelectionError.invalidCompletionCount(completionCount)
        }
        guard bestScore >= 0, bestScore <= 100 else {
            throw ExerciseSelectionError.invalidScore(bestScore)
        }
        guard averageScore >= 0, averageScore <= 100 else {
            throw ExerciseSelectionError.invalidScore(averageScore)
        }
        guard totalTimeSpent >= 0 else {
            throw ExerciseSelectionError.invalidScore(totalTimeSpent)
        }

        self.exerciseId = exerciseId
        self.completionCount = completionCount
        self.bestScore = bestScore
        self.averageScore = averageScore
        self.lastAttemptDate = lastAttemptDate
        self.totalTimeSpent = totalTimeSpent
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var scorePercentage: Double {
        min(max(bestScore, 0), 100)
    }

    var averageScorePercentage: Double {
        min(max(averageScore, 0), 100)
    }
}
