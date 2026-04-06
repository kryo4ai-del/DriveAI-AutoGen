import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var examDate: Date? = nil

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}
