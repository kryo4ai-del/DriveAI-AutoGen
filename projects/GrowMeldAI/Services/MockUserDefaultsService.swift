import Foundation

final class MockUserDefaultsService: @unchecked Sendable {
    private(set) var savedProfile: UserProfile?
    private(set) var savedAttempts: [QuestionAttempt] = []
    var hasCompletedOnboarding = false

    func saveUserProfile(_ profile: UserProfile) throws {
        self.savedProfile = profile
    }

    func loadUserProfile() -> UserProfile? {
        return savedProfile
    }

    func deleteUserProfile() {
        savedProfile = nil
    }

    func saveQuestionAttempt(_ attempt: QuestionAttempt) throws {
        savedAttempts.append(attempt)
    }

    func loadQuestionAttempts() -> [QuestionAttempt] {
        return savedAttempts
    }

    func deleteQuestionAttempts() {
        savedAttempts.removeAll()
    }

    func setHasCompletedOnboarding(_ completed: Bool) {
        self.hasCompletedOnboarding = completed
    }
}