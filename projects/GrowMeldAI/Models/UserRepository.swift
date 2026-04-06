import Foundation

protocol UserRepository {
    func fetchUserProgress() async throws -> UserProgress
    func updateUserProgress(_ progress: UserProgress) async throws
    func setExamDate(_ date: Date) async throws
    func hasCompletedOnboarding() -> Bool
    func markOnboardingComplete() throws
}