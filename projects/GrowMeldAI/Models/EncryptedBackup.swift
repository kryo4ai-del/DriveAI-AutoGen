import Foundation
import CryptoKit

struct EncryptedBackup {
    let ciphertext: Data
    let iv: Data
    let tag: Data
    let algorithm: String
}

enum BackupError: Error, LocalizedError {
    case encryptionFailed(String)
    case decryptionFailed(String)
    case keyGenerationFailed

    var errorDescription: String? {
        switch self {
        case .encryptionFailed(let msg): return "Encryption failed: \(msg)"
        case .decryptionFailed(let msg): return "Decryption failed: \(msg)"
        case .keyGenerationFailed: return "Key generation failed"
        }
    }
}

enum BackupCrypto {
    private static let masterKeyKey = "com.growmeldai.backup.masterkey"

    static func getMasterKey() throws -> SymmetricKey {
        if let data = UserDefaults.standard.data(forKey: masterKeyKey) {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        UserDefaults.standard.set(keyData, forKey: masterKeyKey)
        return key
    }

    static func encrypt(_ data: Data) throws -> EncryptedBackup {
        let key = try getMasterKey()
        let nonce = try AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)

        return EncryptedBackup(
            ciphertext: sealedBox.ciphertext,
            iv: Data(nonce),
            tag: sealedBox.tag,
            algorithm: "AES-256-GCM"
        )
    }

    static func decrypt(_ backup: EncryptedBackup) throws -> Data {
        let key = try getMasterKey()
        let nonce = try AES.GCM.Nonce(data: backup.iv)
        let sealedBox = try AES.GCM.SealedBox(
            nonce: nonce,
            ciphertext: backup.ciphertext,
            tag: backup.tag
        )
        return try AES.GCM.open(sealedBox, using: key)
    }
}