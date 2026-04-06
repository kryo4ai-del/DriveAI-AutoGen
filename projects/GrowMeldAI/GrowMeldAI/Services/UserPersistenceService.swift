// Services/UserPersistenceService.swift
import Foundation
import Combine

final class UserPersistenceService: ObservableObject {
    @Published private(set) var userProfile: UserProfile?

    private let userDefaults = UserDefaults.standard
    private let userProfileKey = "userProfile"

    init() {
        loadUserProfile()
    }

    func saveUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveToUserDefaults()
    }

    func updateExamDate(_ date: Date) {
        guard var profile = userProfile else { return }
        profile.examDate = date
        userProfile = profile
        saveToUserDefaults()
    }

    private func saveToUserDefaults() {
        guard let profile = userProfile else { return }
        if let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: userProfileKey)
        }
    }

    private func loadUserProfile() {
        guard let data = userDefaults.data(forKey: userProfileKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return
        }
        userProfile = profile
    }
}