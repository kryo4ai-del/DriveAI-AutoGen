// Services/Purchases/KeychainStorage.swift
import Foundation
import Security
import os.log

private let logger = Logger(subsystem: "com.driveai", category: "Keychain")

final class KeychainStorage {
    enum KeychainError: LocalizedError {
        case storeFailed(OSStatus)
        case retrieveFailed(OSStatus)
        case itemNotFound
        
        var errorDescription: String? {
            switch self {
            case .storeFailed(let status):
                return "Keychain store failed (\(status))"
            case .retrieveFailed(let status):
                return "Keychain retrieve failed (\(status))"
            case .itemNotFound:
                return "Item not found in Keychain"
            }
        }
    }
    
    private let service: String
    private static let defaultService = "com.driveai.purchases"
    
    init(service: String = KeychainStorage.defaultService) {
        #if DEBUG
        self.service = service + ".debug"
        #else
        self.service = service
        #endif
        logger.info("Keychain service initialized: \(self.service)")
    }
    
    // MARK: - Store
    
    func store(_ data: Data, for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete old item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            logger.error("Failed to store keychain item: \(status)")
            throw KeychainError.storeFailed(status)
        }
        logger.debug("Stored keychain item: \(account)")
    }
    
    // MARK: - Retrieve
    
    func retrieve(for account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            logger.error("Failed to retrieve keychain item: \(status)")
            throw KeychainError.retrieveFailed(status)
        }
        
        guard let data = result as? Data else {
            logger.error("Keychain item not found: \(account)")
            throw KeychainError.itemNotFound
        }
        
        return data
    }
    
    // MARK: - Delete
    
    func delete(for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to delete keychain item: \(status)")
            throw KeychainError.retrieveFailed(status)
        }
        logger.debug("Deleted keychain item: \(account)")
    }
}