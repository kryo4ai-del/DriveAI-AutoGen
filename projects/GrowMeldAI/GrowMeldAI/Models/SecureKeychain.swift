import Foundation
import CryptoKit

/// Secure Keychain abstraction for AES-GCM key storage
final class SecureKeychain {
    static let shared = SecureKeychain()
    
    private let service = "com.driveai.backup"
    private var keyCache: [String: SymmetricKey] = [:]
    
    /// Get or create encryption key for a given identifier
    func getOrCreateKey(for identifier: String) throws -> SymmetricKey {
        // Check cache first
        if let cached = keyCache[identifier] {
            return cached
        }
        
        // Try to load from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        let key: SymmetricKey
        
        if status == errSecSuccess, let keyData = result as? Data {
            // Key exists, load it
            key = SymmetricKey(data: keyData)
        } else if status == errSecItemNotFound {
            // Create new key
            key = SymmetricKey(size: .bits256)
            
            // Save to Keychain
            let keyData = key.withUnsafeBytes { Data($0) }
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: identifier,
                kSecValueData as String: keyData,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw BackupError.encryptionFailed("Failed to store key in Keychain: \(addStatus)")
            }
        } else {
            throw BackupError.encryptionFailed("Keychain error: \(status)")
        }
        
        // Cache for session
        keyCache[identifier] = key
        return key
    }
    
    /// Clear key from Keychain (for reset/logout scenarios)
    func deleteKey(for identifier: String) throws {
        keyCache.removeValue(forKey: identifier)
        
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier
        ]
        
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw BackupError.encryptionFailed("Failed to delete key from Keychain: \(status)")
        }
    }
}