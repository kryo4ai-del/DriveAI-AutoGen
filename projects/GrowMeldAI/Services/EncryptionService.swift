import Foundation
import Security
import CryptoKit

struct EncryptionService {

    static func getMasterKey() throws -> SymmetricKey {
        if let existingKey = try KeychainStorage().retrieveKey("backup-master-key") {
            return existingKey
        }
        let newKey = SymmetricKey(size: .bits256)
        try KeychainStorage().storeKey(newKey, identifier: "backup-master-key")
        return newKey
    }

    static func encrypt(_ data: Data) throws -> (ciphertext: Data, iv: Data, tag: Data) {
        let key = try getMasterKey()
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        return (
            ciphertext: sealedBox.ciphertext,
            iv: Data(nonce),
            tag: sealedBox.tag
        )
    }

    static func decrypt(ciphertext: Data, iv: Data, tag: Data) throws -> Data {
        let key = try getMasterKey()
        let nonce = try AES.GCM.Nonce(data: iv)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        return try AES.GCM.open(sealedBox, using: key)
    }
}

struct KeychainStorage {

    func storeKey(_ key: SymmetricKey, identifier: String) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: identifier,
            kSecValueData: keyData,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionError.keychainError(status)
        }
    }

    func retrieveKey(_ identifier: String) throws -> SymmetricKey? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: identifier,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let keyData = result as? Data else {
            throw EncryptionError.keychainError(status)
        }
        return SymmetricKey(data: keyData)
    }
}

enum EncryptionError: LocalizedError {
    case keychainError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .keychainError(let status):
            return "Keychain error with status: \(status)"
        }
    }
}