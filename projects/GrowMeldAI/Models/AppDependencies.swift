import Foundation

// MARK: - Implementations

final class AppLocalDataService {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try encoder.encode(object)
        userDefaults.set(data, forKey: key)
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try decoder.decode(type, from: data)
    }

    func delete(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

final class AppProgressTracker {
    private(set) var currentProgress: Double = 0.0

    func updateProgress(_ value: Double) {
        currentProgress = max(0.0, min(1.0, value))
    }

    func reset() {
        currentProgress = 0.0
    }
}

final class AppUserPreferences {
    static let shared = AppUserPreferences()

    private let defaults: UserDefaults

    private enum Keys {
        static let notificationsEnabled = "notificationsEnabled"
        static let theme = "theme"
        static let language = "language"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }

    var theme: String {
        get { defaults.string(forKey: Keys.theme) ?? "default" }
        set { defaults.set(newValue, forKey: Keys.theme) }
    }

    var language: String {
        get { defaults.string(forKey: Keys.language) ?? "en" }
        set { defaults.set(newValue, forKey: Keys.language) }
    }
}

// MARK: - AppDependencies

struct AppDependencies {
    let dataService: AppLocalDataService
    let progressTracker: AppProgressTracker
    let preferences: AppUserPreferences

    static func makeForApp() -> AppDependencies {
        return AppDependencies(
            dataService: AppLocalDataService(),
            progressTracker: AppProgressTracker(),
            preferences: AppUserPreferences.shared
        )
    }

    #if DEBUG
    static func makeForTesting(
        dataService: AppLocalDataService? = nil,
        progressTracker: AppProgressTracker? = nil,
        preferences: AppUserPreferences? = nil
    ) -> AppDependencies {
        return AppDependencies(
            dataService: dataService ?? AppLocalDataService(),
            progressTracker: progressTracker ?? AppProgressTracker(),
            preferences: preferences ?? AppUserPreferences()
        )
    }
    #endif
}