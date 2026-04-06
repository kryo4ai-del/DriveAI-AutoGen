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

enum ConsentCategory: String, CaseIterable, Codable {
    case analytics = "analytics"
    case personalization = "personalization"
    case marketing = "marketing"
    case crashReporting = "crash_reporting"
    case performanceMonitoring = "performance_monitoring"

    var displayName: String {
        switch self {
        case .analytics:            return "Analytics"
        case .personalization:      return "Personalization"
        case .marketing:            return "Marketing"
        case .crashReporting:       return "Crash Reporting"
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
    @Published private(set) var hasUserResponded: Bool = false
    @Published private(set) var currentPolicyVersion: String = AppConsentManager.policyVersion

    // MARK: - Private

    private let storage: AppConsentStorageService
    private let respondedKey = "com.growmeldai.consent.hasResponded"
    private let respondedVersionKey = "com.growmeldai.consent.respondedVersion"

    // MARK: - Initializer

    init(storage: AppConsentStorageService = AppConsentStorageService()) {
        self.storage = storage
        self.currentPolicyVersion = AppConsentManager.policyVersion
        load()
    }

    // MARK: - Load / Save

    private func load() {
        let saved = storage.loadPreferences()
        if saved.isEmpty {
            preferences = ConsentCategory.allCases.map { category in
                AppConsentPreference(
                    category: category.rawValue,
                    isGranted: false,
                    grantedAt: nil,
                    version: AppConsentManager.policyVersion
                )
            }
        } else {
            preferences = saved
        }
        auditLog = storage.loadAuditLog()
        hasUserResponded = UserDefaults.standard.bool(forKey: respondedKey)
    }

    private func persist() {
        storage.savePreferences(preferences)
        storage.saveAuditLog(auditLog)
    }

    // MARK: - Public API

    /// Returns the current consent state for a given category
    func isGranted(for category: ConsentCategory) -> Bool {
        preferences.first { $0.category == category.rawValue }?.isGranted ?? false
    }

    /// Updates consent for a specific category
    func setConsent(for category: ConsentCategory, granted: Bool) {
        let previous = preferences.first { $0.category == category.rawValue }?.isGranted

        let updated = AppConsentPreference(
            category: category.rawValue,
            isGranted: granted,
            grantedAt: granted ? Date() : nil,
            version: AppConsentManager.policyVersion
        )

        if let index = preferences.firstIndex(where: { $0.category == category.rawValue }) {
            preferences[index] = updated
        } else {
            preferences.append(updated)
        }

        let entry = AppConsentAuditEntry(
            category: category.rawValue,
            previousValue: previous,
            newValue: granted,
            policyVersion: AppConsentManager.policyVersion
        )
        auditLog.append(entry)
        persist()
    }

    /// Grants all consent categories
    func grantAll() {
        for category in ConsentCategory.allCases {
            setConsent(for: category, granted: true)
        }
        markUserResponded()
    }

    /// Denies all optional consent categories
    func denyAll() {
        for category in ConsentCategory.allCases where !category.isRequired {
            setConsent(for: category, granted: false)
        }
        markUserResponded()
    }

    /// Saves current selections and marks user as having responded
    func saveSelections() {
        markUserResponded()
        persist()
    }

    /// Marks that the user has responded to the consent prompt
    func markUserResponded() {
        hasUserResponded = true
        UserDefaults.standard.set(true, forKey: respondedKey)
        UserDefaults.standard.set(AppConsentManager.policyVersion, forKey: respondedVersionKey)
    }

    /// Returns true if the user needs to re-consent due to policy update
    func requiresReconsent() -> Bool {
        guard hasUserResponded else { return true }
        let respondedVersion = UserDefaults.standard.string(forKey: respondedVersionKey) ?? ""
        return respondedVersion != AppConsentManager.policyVersion
    }

    /// Resets all consent data (e.g. for testing or account deletion)
    func resetAll() {
        storage.clearAll()
        UserDefaults.standard.removeObject(forKey: respondedKey)
        UserDefaults.standard.removeObject(forKey: respondedVersionKey)
        preferences = ConsentCategory.allCases.map { category in
            AppConsentPreference(
                category: category.rawValue,
                isGranted: false,
                grantedAt: nil,
                version: AppConsentManager.policyVersion
            )
        }
        auditLog = []
        hasUserResponded = false
    }

    // MARK: - Audit

    /// Returns audit entries filtered by category
    func auditEntries(for category: ConsentCategory) -> [AppConsentAuditEntry] {
        auditLog.filter { $0.category == category.rawValue }
    }

    /// Returns a summary of current consent state
    func consentSummary() -> [String: Bool] {
        var summary: [String: Bool] = [:]
        for preference in preferences {
            summary[preference.category] = preference.isGranted
        }
        return summary
    }

    /// Returns preferences that match the current policy version
    func currentVersionPreferences() -> [AppConsentPreference] {
        preferences.filter { $0.version == AppConsentManager.policyVersion }
    }

    /// Returns preferences that are outdated (from a previous policy version)
    func outdatedPreferences() -> [AppConsentPreference] {
        preferences.filter { $0.version != AppConsentManager.policyVersion }
    }
}