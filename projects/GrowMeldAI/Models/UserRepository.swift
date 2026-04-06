import Foundation

protocol UserRepository {
    func fetchUserProgress() async throws -> Models.UserProgress
    func updateUserProgress(_ progress: Models.UserProgress) async throws
    func setExamDate(_ date: Date) async throws
    func hasCompletedOnboarding() -> Bool
    func markOnboardingComplete() throws
}