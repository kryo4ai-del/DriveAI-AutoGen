import Foundation

// MARK: - Concrete Implementations

final class AppLocalDataService: LocalDataServiceProtocol {
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

final class AppProgressTracker: ProgressTrackerProtocol {
    private(set) var currentProgress: Double = 0.0

    func updateProgress(_ value: Double) {
        currentProgress = max(0.0, min(1.0, value))
    }

    func reset() {
        currentProgress = 0.0
    }
}

protocol ProgressTrackerProtocol: AnyObject {
    var currentProgress: Double { get }
    func updateProgress(_ value: Double)
    func reset()
}

protocol UserPreferencesProtocol: AnyObject {
    var notificationsEnabled: Bool { get set }
    var theme: String { get set }
    var language: String { get set }
}

final class AppUserPreferences: UserPreferencesProtocol {
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
    let dataService: any LocalDataServiceProtocol
    let progressTracker: any ProgressTrackerProtocol
    let preferences: any UserPreferencesProtocol

    static func makeForApp() -> AppDependencies {
        let prefs = AppUserPreferences.shared
        let dataService = AppLocalDataService()
        let tracker = AppProgressTracker()
        return AppDependencies(
            dataService: dataService,
            progressTracker: tracker,
            preferences: prefs
        )
    }

    #if DEBUG
    static func makeForTesting(
        dataService: (any LocalDataServiceProtocol)? = nil,
        progressTracker: (any ProgressTrackerProtocol)? = nil,
        preferences: (any UserPreferencesProtocol)? = nil
    ) -> AppDependencies {
        return AppDependencies(
            dataService: dataService ?? MockDataService(),
            progressTracker: progressTracker ?? MockProgressTracker(),
            preferences: preferences ?? MockUserPreferences()
        )
    }
    #endif
}

// MARK: - Mock Implementations (DEBUG only)

#if DEBUG
final class MockDataService: LocalDataServiceProtocol {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func save<T: Codable>(_ object: T, forKey key: String) throws {
        storage[key] = try encoder.encode(object)
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = storage[key] else { return nil }
        return try decoder.decode(type, from: data)
    }

    func delete(forKey key: String) {
        storage.removeValue(forKey: key)
    }
}

final class MockProgressTracker: ProgressTrackerProtocol {
    private(set) var currentProgress: Double = 0.0

    func updateProgress(_ value: Double) {
        currentProgress = max(0.0, min(1.0, value))
    }

    func reset() {
        currentProgress = 0.0
    }
}

final class MockUserPreferences: UserPreferencesProtocol {
    var notificationsEnabled: Bool = true
    var theme: String = "default"
    var language: String = "en"
}
#endif