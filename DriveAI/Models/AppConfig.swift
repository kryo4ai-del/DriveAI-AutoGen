import Foundation

/// Global app configuration.
/// Controls developer tools visibility and shared UserDefaults keys.
struct AppConfig {

    // MARK: - Developer mode

    /// When true, developer tools (Sample Validation, Debug Panel, Reset Onboarding)
    /// are visible in Settings. Toggle at runtime in Settings → Developer.
    static var isDeveloperMode: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.developerMode) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.developerMode) }
    }

    // MARK: - UserDefaults keys

    enum Keys {
        static let userData             = "userData"
        static let onboardingCompleted  = "onboardingCompleted"
        static let developerMode        = "driveai_developer_mode"
    }
}
