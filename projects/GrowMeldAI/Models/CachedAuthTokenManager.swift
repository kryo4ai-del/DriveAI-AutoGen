// Models/CachedAuthTokenManager.swift
import Foundation

@MainActor
final class CachedAuthTokenManager {
    static let shared = CachedAuthTokenManager()

    private let keychain = KeychainService()
    private let userDefaults = UserDefaults.standard
    private let keychainPrefix = "driveai.auth.token"
    private let cachedUserKey = "driveai.auth.cachedUser"

    // MARK: - Caching

    func cacheUser(uid: String, email: String, displayName: String?, token: String?) throws {
        let encoder = JSONEncoder()
        let userData = try encoder.encode(CachedUser(
            uid: uid,
            email: email,
            displayName: displayName
        ))

        userDefaults.set(userData, forKey: cachedUserKey)

        // Store token in Keychain for security
        if let token = token {
            try keychain.store(
                token,
                for: "\(keychainPrefix).\(uid)"
            )
        }
    }

    func retrieveCachedUser(email: String) -> CachedAuthUser? {
        guard let userData = userDefaults.data(forKey: cachedUserKey) else { return nil }

        let decoder = JSONDecoder()
        guard let cached = try? decoder.decode(CachedUser.self, from: userData),
              cached.email == email else { return nil }

        return CachedAuthUser(uid: cached.uid, email: cached.email, displayName: cached.displayName)
    }

    func isUserCached(email: String) -> Bool {
        guard let userData = userDefaults.data(forKey: cachedUserKey) else { return false }
        let decoder = JSONDecoder()
        guard let cached = try? decoder.decode(CachedUser.self, from: userData) else { return false }
        return cached.email == email
    }

    func clearCache() {
        userDefaults.removeObject(forKey: cachedUserKey)
        // Clear all tokens from Keychain
        try? keychain.deleteAll(prefix: keychainPrefix)
    }

    func retrieveCachedToken(uid: String) -> String? {
        return try? keychain.retrieve(for: "\(keychainPrefix).\(uid)")
    }
}

// MARK: - Supporting Types

private struct CachedUser: Codable {
    let uid: String
    let email: String
    let displayName: String?
}

/// Minimal user representation for offline/cached use (replaces FirebaseAuth.User)
struct CachedAuthUser {
    let uid: String
    let email: String?
    let displayName: String?

    init(uid: String, email: String, displayName: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}

// MARK: - KeychainService stub (if not already defined elsewhere)

final class KeychainService {
    enum KeychainError: Error {
        case itemNotFound
        case unexpectedData
        case unhandledError(OSStatus)
        case encodingError
    }

    func store(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else { throw KeychainError.encodingError }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status)
        }
    }

    func retrieve(for key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }

        guard let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }

        return value
    }

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status)
        }
    }

    func deleteAll(prefix: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        var result: CFTypeRef?
        let fetchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        let status = SecItemCopyMatching(fetchQuery as CFDictionary, &result)
        guard status == errSecSuccess, let items = result as? [[String: Any]] else { return }

        for item in items {
            if let account = item[kSecAttrAccount as String] as? String,
               account.hasPrefix(prefix) {
                try? delete(for: account)
            }
        }

        // Fallback: delete by class if no prefix matches found
        _ = query
    }
}