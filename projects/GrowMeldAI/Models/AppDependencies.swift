import Foundation

// MARK: - AppDependencies

struct AppDependencies {
    let dataService: any LocalDataServiceProtocol
    let progressTracker: GrowMeldProgressTracker
    let preferences: GrowMeldUserPreferences

    static func makeForApp() -> AppDependencies {
        let prefs = GrowMeldUserPreferences.shared
        let dataService = GrowMeldLocalDataService()
        let tracker = GrowMeldProgressTracker()
        return AppDependencies(
            dataService: dataService,
            progressTracker: tracker,
            preferences: prefs
        )
    }

    #if DEBUG
    static func makeForTesting(
        dataService: (any LocalDataServiceProtocol)? = nil,
        progressTracker: GrowMeldProgressTracker? = nil,
        preferences: GrowMeldUserPreferences? = nil
    ) -> AppDependencies {
        return AppDependencies(
            dataService: dataService ?? GrowMeldMockDataService(),
            progressTracker: progressTracker ?? GrowMeldProgressTracker(),
            preferences: preferences ?? GrowMeldUserPreferences.shared
        )
    }
    #endif
}

// MARK: - Concrete Implementations

final class GrowMeldLocalDataService: LocalDataServiceProtocol {
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

final class GrowMeldProgressTracker {
    private(set) var currentProgress: Double = 0.0

    func updateProgress(_ value: Double) {
        currentProgress = max(0.0, min(1.0, value))
    }

    func reset() {
        currentProgress = 0.0
    }
}

final class GrowMeldUserPreferences {
    static let shared = GrowMeldUserPreferences()

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

// MARK: - Type Aliases for backward compatibility

typealias AppProgressTracker = GrowMeldProgressTracker
typealias AppUserPreferences = GrowMeldUserPreferences
typealias AppLocalDataService = GrowMeldLocalDataService

// MARK: - Mock Implementations (DEBUG only)

#if DEBUG
final class GrowMeldMockDataService: LocalDataServiceProtocol {
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

typealias MockDataService = GrowMeldMockDataService
#endif