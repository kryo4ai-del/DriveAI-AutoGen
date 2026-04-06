import Foundation
import Security

final class KeychainManager {
    private let service = "com.driveai.auth"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Store User
    
    func storeUser(_ user: AuthUser) throws {
        let data = try encoder.encode(user)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: user.id,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete old entry if exists
        SecItemDelete(query as CFDictionary)
        
        // Add new entry
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }
    
    // MARK: - Retrieve User
    
    func retrieveUser() throws -> AuthUser? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimitOne as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        return try decoder.decode(AuthUser.self, from: data)
    }
    
    // MARK: - Delete User
    
    func deleteUser() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}
