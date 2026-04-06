// Services/Protocols/SpacedRepetitionEngine.swift
import Foundation

protocol SpacedRepetitionEngine: Sendable {
    /// Get questions due for review (based on spaced repetition schedule)
    func getQuestionsForReview(limit: Int) async throws -> [RecommendedQuestion]
    
    /// Mark a question as reviewed
    func markReviewed(questionId: UUID, correct: Bool) async throws
    
    /// Calculate next review date for a question
    func calculateNextReviewDate(
        questionId: UUID,
        currentDifficulty: Int,
        successCount: Int,
        failureCount: Int
    ) async throws -> Date
    
    /// Get readiness metrics for exam
    func getExamReadiness() async throws -> ExamReadiness
}
