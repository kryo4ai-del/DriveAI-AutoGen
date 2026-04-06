import Foundation

protocol UserDefaultsServiceProtocol {
    func saveUserProfile(_ profile: UserProfile)
    func loadUserProfile() async -> UserProfile?
    func setOnboardingComplete(_ value: Bool)
    func isOnboardingComplete() -> Bool
    func clearUserProfile()
}
