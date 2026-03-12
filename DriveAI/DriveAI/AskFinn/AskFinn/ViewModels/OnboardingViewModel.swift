import Foundation
import Combine

class OnboardingViewModel: ObservableObject {

    @Published var examDate: Date
    @Published var isCompleted: Bool

    init() {
        // Default exam date: 3 months from today
        examDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        isCompleted = UserDefaults.standard.bool(forKey: AppConfig.Keys.onboardingCompleted)
    }

    func saveUserData() {
        let user = User(examDate: examDate)
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: AppConfig.Keys.userData)
        }
        UserDefaults.standard.set(true, forKey: AppConfig.Keys.onboardingCompleted)
        isCompleted = true
    }

    /// Resets onboarding -- useful during development (accessible via Settings > Developer).
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: AppConfig.Keys.onboardingCompleted)
        UserDefaults.standard.removeObject(forKey: AppConfig.Keys.userData)
        isCompleted = false
    }
}
