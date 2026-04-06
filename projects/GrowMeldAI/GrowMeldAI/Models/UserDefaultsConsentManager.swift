// UserDefaultsConsentManager.swift
import Foundation

final class UserDefaultsConsentManager: ConsentManager {
    private let userDefaults = UserDefaults.standard

    func grantConsent(type: ConsentType, timestamp: Date) async throws {
        var consents = userDefaults.dictionary(forKey: "consents") ?? [:]
        consents[type.rawValue] = timestamp
        userDefaults.set(consents, forKey: "consents")
    }

    func hasConsentedTo(_ type: ConsentType) -> Bool {
        (userDefaults.dictionary(forKey: "consents")?[type.rawValue] as? Date) != nil
    }

    func getConsentTimestamp(_ type: ConsentType) -> Date? {
        userDefaults.dictionary(forKey: "consents")?[type.rawValue] as? Date
    }

    func withdrawConsent(_ type: ConsentType) async throws {
        var consents = userDefaults.dictionary(forKey: "consents") ?? [:]
        consents.removeValue(forKey: type.rawValue)
        userDefaults.set(consents, forKey: "consents")
    }
}