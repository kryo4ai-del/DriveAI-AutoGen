import Foundation

// MARK: - UserPreferencesProtocol

protocol UserPreferencesProtocol: AnyObject {
    var notificationsEnabled: Bool { get set }
    var theme: String { get set }
    var language: String { get set }
}

// MARK: - AppUserPreferences

final class AppUserPreferences: UserPreferencesProtocol {
    static let shared = AppUserPreferences()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: "notificationsEnabled") }
        set { defaults.set(newValue, forKey: "notificationsEnabled") }
    }

    var theme: String {
        get { defaults.string(forKey: "theme") ?? "default" }
        set { defaults.set(newValue, forKey: "theme") }
    }

    var language: String {
        get { defaults.string(forKey: "language") ?? "en" }
        set { defaults.set(newValue, forKey: "language") }
    }
}

// MARK: - AppDependencies

struct AppDependencies {
    let preferences: any UserPreferencesProtocol

    static func makeForApp() -> AppDependencies {
        return AppDependencies(preferences: AppUserPreferences.shared)
    }
}
