import Foundation
import Security
import CryptoKit

class ConsentStorageService: ConsentStorageServiceProtocol {
    private let storageKey = "driveai.coppa.consent"
    private let keychainKey = "driveai.coppa.key"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods

    func saveConsentRecord(_ record: ConsentRecord) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(record)

        let key = try getOrCreateEncryptionKey()
        let sealedBox = try AES.GCM.seal(jsonData, using: key)

        guard let combined = sealedBox.combined else {
            throw ConsentStorageServiceError.encryptionFailed
        }

        userDefaults.set(combined, forKey: storageKey)
    }

    func loadConsentRecord() -> ConsentRecord? {
        guard let encryptedData = userDefaults.data(forKey: storageKey) else {
            return nil
        }

        do {
            let key = try getOrCreateEncryptionKey()
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(ConsentRecord.self, from: decryptedData)
        } catch {
            print("❌ Decryption failed: \(error)")
            return nil
        }
    }

    func deleteConsentRecord() throws {
        userDefaults.removeObject(forKey: storageKey)
        try deleteEncryptionKey()
    }

    func isConsentValid() -> Bool {
        guard let record = loadConsentRecord() else { return false }
        return record.isValid()
    }

    // MARK: - Private Keychain Methods

    private func getOrCreateEncryptionKey() throws -> CryptoKit.SymmetricKey {
        if let keyData = try loadKeyFromKeychain() {
            return CryptoKit.SymmetricKey(data: keyData)
        }

        let newKey = CryptoKit.SymmetricKey(size: .bits256)
        try saveKeyToKeychain(newKey)
        return newKey
    }

    private func loadKeyFromKeychain() throws -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecReturnData: true,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw ConsentStorageServiceError.keychainError("Load failed: \(status)")
        }
    }

    private func saveKeyToKeychain(_ key: CryptoKit.SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecValueData: keyData,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            throw ConsentStorageServiceError.keychainError("Save failed: \(status)")
        }
    }

    private func deleteEncryptionKey() throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            throw ConsentStorageServiceError.keychainError("Delete failed: \(status)")
        }
    }
}

enum ConsentStorageServiceError: LocalizedError {
    case encryptionFailed
    case keychainError(String)

    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt consent record"
        case .keychainError(let msg):
            return "Keychain error: \(msg)"
        }
    }
}