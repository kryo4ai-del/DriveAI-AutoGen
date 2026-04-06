import Foundation

/// Handles persistence of consent decisions
class NotificationConsentRepository {
    private let userDefaults: UserDefaults
    private let keyPrefix = "driveai.notification.consent."
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Read
    
    func getConsent(for triggerId: String) -> NotificationConsent? {
        guard let data = userDefaults.data(forKey: keyPrefix + triggerId) else {
            return nil
        }
        return try? JSONDecoder().decode(NotificationConsent.self, from: data)
    }
    
    // MARK: - Write
    
    func saveConsent(_ consent: NotificationConsent) throws {
        let data = try JSONEncoder().encode(consent)
        userDefaults.set(data, forKey: keyPrefix + consent.triggerId)
    }
    
    // MARK: - Query
    
    func shouldAskForConsent(triggerId: String) -> Bool {
        guard let consent = getConsent(for: triggerId) else {
            return true // Never asked before
        }
        
        // Check if "never ask again" is still in effect
        if !consent.isValid {
            return true // Expiry passed, ask again
        }
        
        // Already consented or permanently opted out
        switch consent.decision {
        case .allowed:
            return false // User already allowed
        case .denied:
            // User said "not now" — ask again after 7 days
            let timeSinceDenial = Date().timeIntervalSince(consent.decisionDate)
            return timeSinceDenial > ConsentPolicy.minTimeBetweenRetries
        case .neverAskAgain:
            return false // Still within "never ask" window
        }
    }
    
    // MARK: - Deletion (GDPR Article 17)
    
    func deleteAllConsents() throws {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        allKeys
            .filter { $0.hasPrefix(keyPrefix) }
            .forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    func deleteConsent(for triggerId: String) throws {
        userDefaults.removeObject(forKey: keyPrefix + triggerId)
    }
}