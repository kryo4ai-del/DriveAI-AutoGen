// Features/Onboarding/Services/OnboardingStorageService.swift
import Foundation

enum OnboardingStorageError: Error, LocalizedError {
    case saveFailed
    case loadFailed
    case profileNotFound

    var errorDescription: String? {
        switch self {
        case .saveFailed: return "Profil konnte nicht gespeichert werden"
        case .loadFailed: return "Profil konnte nicht geladen werden"
        case .profileNotFound: return "Profil nicht gefunden"
        }
    }
}

final class OnboardingStorageService: OnboardingStorageServiceProtocol {
    private enum Keys {
        static let profile = "onboarding_profile"
        static let completed = "onboarding_completed"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveProfile(_ profile: UserProfile) async throws {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: Keys.profile)
        } catch {
            throw OnboardingStorageError.saveFailed
        }
    }

    func loadProfile() async throws -> UserProfile? {
        guard let data = userDefaults.data(forKey: Keys.profile) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            throw OnboardingStorageError.loadFailed
        }
    }

    func completeOnboarding(profile: UserProfile) async throws {
        try await saveProfile(profile)
        userDefaults.set(true, forKey: Keys.completed)
    }
}