import Foundation
// Models/CategoryProgress.swift
struct CategoryProgress: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let correctAnswers: Int
    let totalQuestions: Int
    let lastUpdated: Date
    
    // Convenience init for tests
    init(
        categoryId: String,
        correctAnswers: Int,
        totalQuestions: Int,
        id: UUID = UUID(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.categoryId = categoryId
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.lastUpdated = lastUpdated
    }
}