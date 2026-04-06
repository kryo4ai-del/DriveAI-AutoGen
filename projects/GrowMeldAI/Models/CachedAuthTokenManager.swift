import Foundation

@MainActor
final class CachedAuthTokenManager {
    static let shared = CachedAuthTokenManager()

    private let userDefaults = UserDefaults.standard
    private let keychainPrefix = "driveai.auth.token"
    private let cachedUserKey = "driveai.auth.cachedUser"

    private init() {}

    // MARK: - Caching

    func cacheUser(uid: String, email: String, displayName: String?, token: String?) throws {
        let encoder = JSONEncoder()
        let userData = try encoder.encode(CachedUser(
            uid: uid,
            email: email,
            displayName: displayName
        ))

        userDefaults.set(userData, forKey: cachedUserKey)

        if let token = token {
            try storeInKeychain(token, for: "\(keychainPrefix).\(uid)")
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
        deleteAllFromKeychain(prefix: keychainPrefix)
    }

    func retrieveCachedToken(uid: String) -> String? {
        return try? retrieveFromKeychain(for: "\(keychainPrefix).\(uid)")
    }

    // MARK: - Keychain Helpers

    private func storeInKeychain(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainHelperError.encodingError
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainHelperError.unhandledError(status)
        }
    }

    private func retrieveFromKeychain(for key: String) throws -> String {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            throw KeychainHelperError.itemNotFound
        }

        guard let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainHelperError.unexpectedData
        }

        return value
    }

    private func deleteAllFromKeychain(prefix: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword
        ]

        let searchQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecReturnAttributes: kCFBooleanTrue as Any,
            kSecReturnData: kCFBooleanFalse as Any,
            kSecMatchLimit: kSecMatchLimitAll
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &result)

        guard status == errSecSuccess,
              let items = result as? [[CFString: Any]] else { return }

        for item in items {
            guard let account = item[kSecAttrAccount] as? String,
                  account.hasPrefix(prefix) else { continue }

            let deleteQuery: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account
            ]
            SecItemDelete(deleteQuery as CFDictionary)
        }

        _ = query
    }
}

// MARK: - Supporting Types

private struct CachedUser: Codable {
    let uid: String
    let email: String
    let displayName: String?
}

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

private enum KeychainHelperError: Error {
    case itemNotFound
    case unexpectedData
    case unhandledError(OSStatus)
    case encodingError
}