// Services/Analytics/GDPR/ConsentManager.swift

import Foundation

/// Manages user consent for analytics collection per GDPR/DSGVO
@MainActor
final class ConsentManager: Sendable {
    static let shared = ConsentManager()
    
    @Published private(set) var analyticsConsentGiven: Bool = false
    @Published private(set) var consentTimestamp: Date?
    
    private let userDefaults: UserDefaults
    private let keychain: KeychainService
    
    private let consentKey = "driveai.analytics.consent"
    private let consentTimestampKey = "driveai.analytics.consent.timestamp"
    private let consentVersionKey = "driveai.analytics.consent.version"
    
    /// Current consent form version (bump on legal changes)
    private let currentConsentVersion = 1
    
    init(
        userDefaults: UserDefaults = .standard,
        keychain: KeychainService = .shared
    ) {
        self.userDefaults = userDefaults
        self.keychain = keychain
        
        // Load persisted consent state
        analyticsConsentGiven = userDefaults.bool(forKey: consentKey)
        
        if let timestamp = userDefaults.object(forKey: consentTimestampKey) as? Date {
            consentTimestamp = timestamp
        }
        
        // Apply analytics collection state without Firebase dependency
        AnalyticsProxy.setCollectionEnabled(analyticsConsentGiven)
    }
    
    /// Update user's analytics consent
    /// - Parameter granted: true to enable, false to disable
    func setAnalyticsConsent(_ granted: Bool) {
        analyticsConsentGiven = granted
        consentTimestamp = Date()
        
        // Persist decision
        userDefaults.set(granted, forKey: consentKey)
        userDefaults.set(consentTimestamp, forKey: consentTimestampKey)
        userDefaults.set(currentConsentVersion, forKey: consentVersionKey)
        
        // Apply analytics collection state
        AnalyticsProxy.setCollectionEnabled(granted)
        
        // Securely log consent audit trail
        Task {
            await keychain.logConsentChange(
                granted: granted,
                timestamp: consentTimestamp ?? Date()
            )
        }
    }
    
    /// Check if consent form needs to be re-shown (e.g., after legal update)
    func needsConsentRefresh() -> Bool {
        let savedVersion = userDefaults.integer(forKey: consentVersionKey)
        return savedVersion < currentConsentVersion
    }
    
    /// Clear all consent data (used in account deletion)
    func clearConsentData() {
        analyticsConsentGiven = false
        consentTimestamp = nil
        
        userDefaults.removeObject(forKey: consentKey)
        userDefaults.removeObject(forKey: consentTimestampKey)
        userDefaults.removeObject(forKey: consentVersionKey)
        
        AnalyticsProxy.setCollectionEnabled(false)
    }
}

// MARK: - Analytics Proxy (Firebase abstraction layer)

/// Proxy for Firebase Analytics calls — allows conditional linking
/// and avoids hard compile-time dependency on FirebaseAnalytics module.
enum AnalyticsProxy {
    /// Toggle analytics data collection.
    /// When FirebaseAnalytics is linked, this forwards to
    /// `Analytics.setAnalyticsCollectionEnabled(_:)` via ObjC runtime.
    static func setCollectionEnabled(_ enabled: Bool) {
        // Attempt to call Firebase Analytics via Objective-C runtime
        // so this file compiles even when the SDK is not yet integrated.
        let className = "FIRAnalytics"
        let selectorName = "setAnalyticsCollectionEnabled:"
        if
            let cls = NSClassFromString(className) as? NSObjectProtocol,
            let sel = NSSelectorFromString(selectorName) as Selector?,
            (cls as AnyObject).responds(to: sel)
        {
            _ = (cls as AnyObject).perform(sel, with: enabled)
        } else {
            // Firebase not linked — persist intent for later SDK initialisation
            UserDefaults.standard.set(enabled, forKey: "driveai.analytics.proxy.enabled")
            #if DEBUG
            print("[AnalyticsProxy] FirebaseAnalytics not available. Collection enabled: \(enabled)")
            #endif
        }
    }
}

// MARK: - Keychain Service

/// Minimal Keychain service used for consent audit-trail logging.
@MainActor
final class KeychainService: Sendable {
    static let shared = KeychainService()

    private let service = "com.driveai.consentaudit"

    private init() {}

    /// Append an immutable consent-change record to the secure audit trail.
    func logConsentChange(granted: Bool, timestamp: Date) async {
        let entry = ConsentAuditEntry(granted: granted, timestamp: timestamp)
        guard let data = try? JSONEncoder().encode(entry) else { return }

        // Read existing entries
        var entries: [ConsentAuditEntry] = loadEntries()
        entries.append(entry)

        guard let allData = try? JSONEncoder().encode(entries) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "consentLog"
        ]

        let attributes: [CFString: Any] = [kSecValueData: allData]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData] = allData
            SecItemAdd(addQuery as CFDictionary, nil)
        }

        #if DEBUG
        print("[KeychainService] Consent change logged: granted=\(granted) at \(timestamp)")
        _ = data // suppress unused warning
        #endif
    }

    /// Retrieve all stored consent audit entries.
    func loadEntries() -> [ConsentAuditEntry] {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "consentLog",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let entries = try? JSONDecoder().decode([ConsentAuditEntry].self, from: data)
        else { return [] }

        return entries
    }

    /// Remove all consent audit records (used during full account deletion).
    func clearAuditLog() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "consentLog"
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Consent Audit Entry

struct ConsentAuditEntry: Codable, Sendable {
    let granted: Bool
    let timestamp: Date
}