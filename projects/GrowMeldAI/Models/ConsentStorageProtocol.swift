import Foundation
import Security

/// Protocol for consent persistence (Keychain-first, fallback to UserDefaults)
protocol ConsentStorageProtocol {
    func load() -> ConsentStatus
    func save(_ status: ConsentStatus) -> Bool
    func clear() -> Bool
}

class ConsentStorage: ConsentStorageProtocol {
    private let keychainKey = "com.driveai.consent.status"
    private let userDefaultsKey = "com.driveai.consent.status.ud"
    
    // MARK: - Keychain Helper
    
    private func saveToKeychain(_ status: ConsentStatus) -> Bool {
        guard let data = try? JSONEncoder().encode(status) else {
            return false
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing
        SecItemDelete(query as CFDictionary)
        
        // Insert new
        let statusCode = SecItemAdd(query as CFDictionary, nil)
        return statusCode == errSecSuccess
    }
    
    private func loadFromKeychain() -> ConsentStatus? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecReturnData: true
        ]
        
        var result: AnyObject?
        let statusCode = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard statusCode == errSecSuccess,
              let data = result as? Data,
              let consentStatus = try? JSONDecoder().decode(ConsentStatus.self, from: data) else {
            return nil
        }
        
        return consentStatus
    }
    
    // MARK: - Public Interface
    
    func load() -> ConsentStatus {
        // Try Keychain first (more secure)
        if let keychainStatus = loadFromKeychain() {
            return keychainStatus
        }
        
        // Fallback to UserDefaults
        if let raw = UserDefaults.standard.string(forKey: userDefaultsKey),
           let status = ConsentStatus(rawValue: raw) {
            return status
        }
        
        return .undetermined
    }
    
    func save(_ status: ConsentStatus) -> Bool {
        // Atomic write: Keychain first
        let keychainSuccess = saveToKeychain(status)
        
        // Backup to UserDefaults
        UserDefaults.standard.set(status.rawValue, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
        
        return keychainSuccess || true // UserDefaults is fallback
    }
    
    func clear() -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey
        ]
        
        let keychainSuccess = SecItemDelete(query as CFDictionary) == errSecSuccess
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        return keychainSuccess
    }
}