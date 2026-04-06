import Security
import Foundation

@MainActor
final class KeychainService: Sendable {
    static let shared = KeychainService()
    
    private let service = "com.driveai.analytics"
    private let accountKey = "consent.audit.log"
    
    func logConsentChange(granted: Bool, timestamp: Date) async {
        let entry = ConsentAuditEntry(
            granted: granted,
            timestamp: timestamp,
            appVersion: Bundle.main.appVersion,
            osVersion: UIDevice.current.systemVersion
        )
        
        var log = try? retrieveAuditLog()
        log?.append(entry)
        
        try? storeAuditLog(log ?? [entry])
    }
    
    private func storeAuditLog(_ entries: [ConsentAuditEntry]) throws {
        let encoded = try JSONEncoder().encode(entries)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: accountKey,
            kSecValueData as String: encoded,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func retrieveAuditLog() throws -> [ConsentAuditEntry] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: accountKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return []
        }
        
        return try JSONDecoder().decode([ConsentAuditEntry].self, from: data)
    }
}

struct ConsentAuditEntry: Codable, Sendable {
    let granted: Bool
    let timestamp: Date
    let appVersion: String
    let osVersion: String
}