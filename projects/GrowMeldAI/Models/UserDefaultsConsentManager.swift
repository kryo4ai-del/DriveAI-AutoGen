import Foundation

protocol ConsentManager {
    func grantConsent(type: ConsentType, timestamp: Date) async throws
    func hasConsentedTo(_ type: ConsentType) -> Bool
    func getConsentTimestamp(_ type: ConsentType) -> Date?
    func withdrawConsent(_ type: ConsentType) async throws
}

enum ConsentType: String, CaseIterable {
    case analytics = "analytics"
    case marketing = "marketing"
    case personalization = "personalization"
    case dataSharing = "dataSharing"
    case notifications = "notifications"
}

final class UserDefaultsConsentManager: ConsentManager {
    private let userDefaults = UserDefaults.standard
    private let consentsKey = "consents"

    func grantConsent(type: ConsentType, timestamp: Date) async throws {
        var consents = loadConsents()
        consents[type.rawValue] = timestamp.timeIntervalSince1970
        saveConsents(consents)
    }

    func hasConsentedTo(_ type: ConsentType) -> Bool {
        loadConsents()[type.rawValue] != nil
    }

    func getConsentTimestamp(_ type: ConsentType) -> Date? {
        guard let interval = loadConsents()[type.rawValue] else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    func withdrawConsent(_ type: ConsentType) async throws {
        var consents = loadConsents()
        consents.removeValue(forKey: type.rawValue)
        saveConsents(consents)
    }

    private func loadConsents() -> [String: Double] {
        return userDefaults.dictionary(forKey: consentsKey) as? [String: Double] ?? [:]
    }

    private func saveConsents(_ consents: [String: Double]) {
        userDefaults.set(consents, forKey: consentsKey)
    }
}