import Foundation
import CryptoKit

enum BackupError: LocalizedError {
    case encryptionFailed(String)

    var errorDescription: String? {
        switch self {
        case .encryptionFailed(let msg):
            return "Encryption failed: \(msg)"
        }
    }
}

struct EncryptedBackup {
    let ciphertext: Data
    let iv: Data
    let tag: Data
    let algorithm: String
}

struct BackupCrypto {
    static func encrypt(_ data: Data) throws -> EncryptedBackup {
        let key = getMasterKey()
        let nonce = AES.GCM.Nonce()

        let sealedBox: AES.GCM.SealedBox
        do {
            sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        } catch {
            throw BackupError.encryptionFailed(error.localizedDescription)
        }

        return EncryptedBackup(
            ciphertext: sealedBox.ciphertext,
            iv: Data(nonce),
            tag: sealedBox.tag,
            algorithm: "AES-256-GCM"
        )
    }

    static func decrypt(_ backup: EncryptedBackup) throws -> Data {
        let key = getMasterKey()

        let nonce: AES.GCM.Nonce
        do {
            nonce = try AES.GCM.Nonce(data: backup.iv)
        } catch {
            throw BackupError.encryptionFailed("Invalid nonce: \(error.localizedDescription)")
        }

        let sealedBox: AES.GCM.SealedBox
        do {
            sealedBox = try AES.GCM.SealedBox(
                nonce: nonce,
                ciphertext: backup.ciphertext,
                tag: backup.tag
            )
        } catch {
            throw BackupError.encryptionFailed("Invalid sealed box: \(error.localizedDescription)")
        }

        do {
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw BackupError.encryptionFailed("Decryption failed: \(error.localizedDescription)")
        }
    }

    static func getMasterKey() -> SymmetricKey {
        let keychainKey = "com.growmeldai.backup.masterkey"
        if let data = UserDefaults.standard.data(forKey: keychainKey) {
            return SymmetricKey(data: data)
        }
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        UserDefaults.standard.set(keyData, forKey: keychainKey)
        return newKey
    }
}