import Foundation
import Combine

final class AppPrivacyManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let privacyDataKey = "com.driveai.privacy.consentState"

    @Published private(set) var consentState: [DataPurpose: Bool]
    @Published private(set) var hasCompletedOnboarding: Bool

    init() {
        // Load saved consent state or use defaults
        if let savedData = userDefaults.data(forKey: privacyDataKey),
           let decoded = try? JSONDecoder().decode([DataPurpose: Bool].self, from: savedData) {
            self.consentState = decoded
        } else {
            self.consentState = DataPurpose.allCases.reduce(into: [:]) {
                $0[$1] = $1 == .examProgress || $1 == .userProfile
            }
        }

        self.hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedPrivacyOnboarding")
    }

    func saveConsentState() {
        if let encoded = try? JSONEncoder().encode(consentState) {
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
        // In a real app, this would trigger data deletion
        // For now, just reset consent state
        consentState = DataPurpose.allCases.reduce(into: [:]) {
            $0[$1] = $1 == .examProgress || $1 == .userProfile
        }
        saveConsentState()
    }
}