import Foundation
import CryptoKit

struct EncryptedBackup {
    let ciphertext: Data
    let iv: Data
    let tag: Data
    let algorithm: String
}

enum BackupError: Error {
    case encryptionFailed(String)
}

struct BackupCrypto {
    static func encrypt(_ data: Data) throws -> EncryptedBackup {
        let key = try getMasterKey()
        let nonce = AES.GCM.Nonce()

        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)

        let tag = sealedBox.tag

        return EncryptedBackup(
            ciphertext: sealedBox.ciphertext,
            iv: Data(nonce),
            tag: tag,
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

    static func getMasterKey() throws -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
}