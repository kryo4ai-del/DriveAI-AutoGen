// Domain/Coaching/CoachingRepositoryProtocol.swift
import Foundation

protocol CoachingRepositoryProtocol {
    func fetchRecommendations(for userId: String) async throws -> [CoachingRecommendation]
    func saveRecommendation(_ recommendation: CoachingRecommendation) async throws
    func dismissRecommendation(id: UUID, userId: String) async throws
    func fetchDismissedRecommendationIds(for userId: String) async throws -> Set<UUID>
}

// Domain/Readiness/ExamReadinessRepositoryProtocol.swift

protocol ExamReadinessRepositoryProtocol {
    func fetchQuizAttempts(categoryId: String?, limit: Int?) async throws -> [QuizAttempt]
    func saveQuizAttempt(_ attempt: QuizAttempt) async throws
    func fetchUserProfile(_ userId: String) async throws -> User
}