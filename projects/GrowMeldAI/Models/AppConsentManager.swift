import Foundation

// MARK: - Supporting Types

struct AppConsentPreference: Codable, Equatable {
    let category: String
    let isGranted: Bool
    let grantedAt: Date?
    let version: String

    init(category: String, isGranted: Bool, grantedAt: Date? = nil, version: String = AppConsentManager.policyVersion) {
        self.category = category
        self.isGranted = isGranted
        self.grantedAt = grantedAt
        self.version = version
    }
}

struct AppConsentAuditEntry: Codable, Identifiable {
    let id: String
    let category: String
    let previousValue: Bool?
    let newValue: Bool
    let changedAt: Date
    let policyVersion: String

    init(
        id: String = UUID().uuidString,
        category: String,
        previousValue: Bool?,
        newValue: Bool,
        changedAt: Date = Date(),
        policyVersion: String = AppConsentManager.policyVersion
    ) {
        self.id = id
        self.category = category
        self.previousValue = previousValue
        self.newValue = newValue
        self.changedAt = changedAt
        self.policyVersion = policyVersion
    }
}

// MARK: - Storage Service

final class AppConsentStorageService {
    private let defaults: UserDefaults
    private let preferencesKey = "com.growmeldai.consent.preferences"
    private let auditLogKey = "com.growmeldai.consent.auditLog"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func savePreferences(_ preferences: [AppConsentPreference]) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: preferencesKey)
    }

    func loadPreferences() -> [AppConsentPreference] {
        guard
            let data = defaults.data(forKey: preferencesKey),
            let preferences = try? JSONDecoder().decode([AppConsentPreference].self, from: data)
        else { return [] }
        return preferences
    }

    func saveAuditLog(_ entries: [AppConsentAuditEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: auditLogKey)
    }

    func loadAuditLog() -> [AppConsentAuditEntry] {
        guard
            let data = defaults.data(forKey: auditLogKey),
            let entries = try? JSONDecoder().decode([AppConsentAuditEntry].self, from: data)
        else { return [] }
        return entries
    }

    func clearAll() {
        defaults.removeObject(forKey: preferencesKey)
        defaults.removeObject(forKey: auditLogKey)
    }
}

// MARK: - Consent Category

enum AppConsentCategory: String, CaseIterable, Codable {
    case analytics = "analytics"
    case personalization = "personalization"
    case marketing = "marketing"
    case crashReporting = "crash_reporting"
    case performanceMonitoring = "performance_monitoring"

    var displayName: String {
        switch self {
        case .analytics:             return "Analytics"
        case .personalization:       return "Personalization"
        case .marketing:             return "Marketing"
        case .crashReporting:        return "Crash Reporting"
        case .performanceMonitoring: return "Performance Monitoring"
        }
    }

    var description: String {
        switch self {
        case .analytics:
            return "Helps us understand how you use the app to improve features."
        case .personalization:
            return "Allows us to tailor content and recommendations to your preferences."
        case .marketing:
            return "Enables relevant promotional communications and offers."
        case .crashReporting:
            return "Automatically reports crashes to help us fix bugs faster."
        case .performanceMonitoring:
            return "Monitors app performance to ensure a smooth experience."
        }
    }

    var isRequired: Bool {
        return false
    }
}

// MARK: - AppConsentManager

@MainActor
final class AppConsentManager: ObservableObject {

    // MARK: - Constants

    static let policyVersion = "1.0.0"

    // MARK: - Published State

    @Published private(set) var preferences: [AppConsentPreference] = []
    @Published private(set) var auditLog: [AppConsentAuditEntry] = []
    @Published private(set) var hasCompletedInitialConsent: Bool = false

    // MARK: - Private

    private let storage: AppConsentStorageService
    private let hasCompletedConsentKey = "com.growmeldai.consent.hasCompleted"

    // MARK: - Init

    init(storage: AppConsentStorageService = AppConsentStorageService()) {
        self.storage = storage
        self.preferences = storage.loadPreferences()
        self.auditLog = storage.loadAuditLog()
        self.hasCompletedInitialConsent = UserDefaults.standard.bool(forKey: hasCompletedConsentKey)
    }

    // MARK: - Public API

    func isGranted(_ category: AppConsentCategory) -> Bool {
        preferences.first { $0.category == category.rawValue }?.isGranted ?? false
    }

    func setConsent(_ category: AppConsentCategory, granted: Bool) {
        let previous = preferences.first { $0.category == category.rawValue }?.isGranted
        let newPref = AppConsentPreference(
            category: category.rawValue,
            isGranted: granted,
            grantedAt: granted ? Date() : nil
        )
        if let index = preferences.firstIndex(where: { $0.category == category.rawValue }) {
            preferences[index] = newPref
        } else {
            preferences.append(newPref)
        }
        storage.savePreferences(preferences)

        let entry = AppConsentAuditEntry(
            category: category.rawValue,
            previousValue: previous,
            newValue: granted
        )
        auditLog.append(entry)
        storage.saveAuditLog(auditLog)
    }

    func grantAll() {
        for category in AppConsentCategory.allCases {
            setConsent(category, granted: true)
        }
    }

    func revokeAll() {
        for category in AppConsentCategory.allCases {
            setConsent(category, granted: false)
        }
    }

    func completeInitialConsent() {
        hasCompletedInitialConsent = true
        UserDefaults.standard.set(true, forKey: hasCompletedConsentKey)
    }

    func resetAll() {
        preferences = []
        auditLog = []
        hasCompletedInitialConsent = false
        storage.clearAll()
        UserDefaults.standard.removeObject(forKey: hasCompletedConsentKey)
    }
}