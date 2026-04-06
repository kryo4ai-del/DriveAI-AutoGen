// Models/ProgressTracker.swift
import Foundation

// MARK: - Supporting Types

struct UserProgress: Sendable {
    let categoryId: UUID?
    let correctCount: Int
    let totalCount: Int
    let percentage: Double
    let lastUpdated: Date

    init(
        categoryId: UUID? = nil,
        correctCount: Int,
        totalCount: Int,
        lastUpdated: Date = Date()
    ) {
        self.categoryId = categoryId
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.percentage = totalCount > 0 ? Double(correctCount) / Double(totalCount) * 100.0 : 0.0
        self.lastUpdated = lastUpdated
    }
}

struct WeakCategoryInfo: Sendable {
    let categoryId: UUID
    let categoryName: String
    let correctCount: Int
    let totalCount: Int
    let percentage: Double

    init(
        categoryId: UUID,
        categoryName: String,
        correctCount: Int,
        totalCount: Int
    ) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.percentage = totalCount > 0 ? Double(correctCount) / Double(totalCount) * 100.0 : 0.0
    }
}

// MARK: - Protocol

protocol ProgressTracker: Sendable {
    /// Get progress for a specific category
    func getProgress(categoryId: UUID) async throws -> UserProgress

    /// Get overall user progress
    func getOverallProgress() async throws -> UserProgress

    /// Record an answer
    func recordAnswer(questionId: UUID, isCorrect: Bool, timestamp: Date) async throws

    /// Get streak (consecutive days with activity)
    func getCurrentStreak() async throws -> Int

    /// Get weak categories (lowest performance)
    func getWeakCategories(limit: Int) async throws -> [WeakCategoryInfo]
}