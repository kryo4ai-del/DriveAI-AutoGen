import Foundation
import Combine

enum DataPurpose: String, CaseIterable, Codable {
    case examProgress
    case userProfile
    case analytics
    case crashReporting
    case personalization
}

final class AppPrivacyManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let privacyDataKey = "com.driveai.privacy.consentState"

    @Published private(set) var consentState: [DataPurpose: Bool]
    @Published private(set) var hasCompletedOnboarding: Bool

    init() {
        if let savedData = userDefaults.data(forKey: "com.driveai.privacy.consentState"),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: savedData) {
            var state: [DataPurpose: Bool] = [:]
            for purpose in DataPurpose.allCases {
                state[purpose] = decoded[purpose.rawValue] ?? (purpose == .examProgress || purpose == .userProfile)
            }
            self.consentState = state
        } else {
            var state: [DataPurpose: Bool] = [:]
            for purpose in DataPurpose.allCases {
                state[purpose] = (purpose == .examProgress || purpose == .userProfile)
            }
            self.consentState = state
        }

        self.hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedPrivacyOnboarding")
    }

    func saveConsentState() {
        var stringKeyed: [String: Bool] = [:]
        for (purpose, value) in consentState {
            stringKeyed[purpose.rawValue] = value
        }
        if let encoded = try? JSONEncoder().encode(stringKeyed) {
            userDefaults.set(encoded, forKey: privacyDataKey)
        }
    }

    func markOnboardingCompleted() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: "hasCompletedPrivacyOnboarding")
    }

    func canCollectData(for purpose: DataPurpose) -> Bool {
        consentState[purpose] ?? false
    }

    func requestDataDeletion() {
        var state: [DataPurpose: Bool] = [:]
        for purpose in DataPurpose.allCases {
            state[purpose] = (purpose == .examProgress || purpose == .userProfile)
        }
        consentState = state
        saveConsentState()
    }
}