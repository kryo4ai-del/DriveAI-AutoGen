import Foundation
import CryptoKit

protocol BackupEncryptionService: AnyObject {
    func encrypt(payload: BackupPayload) throws -> Data
    func decrypt(data: Data) throws -> BackupPayload
}

@MainActor
final class CryptoKitBackupEncryptionService: BackupEncryptionService {
    private let keychain: SecureKeychain
    
    init(keychain: SecureKeychain = .shared) {
        self.keychain = keychain
    }
    
    func encrypt(payload: BackupPayload) throws -> Data {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(payload)
        
        let key = try keychain.getOrCreateKey(for: "backup_encryption")
        let sealedBox = try AES.GCM.seal(jsonData, using: key)
        
        guard let combined = sealedBox.combined else {
            throw BackupError.encryptionFailed("Unable to combine AES-GCM components")
        }
        
        return combined
    }
    
    func decrypt(data: Data) throws -> BackupPayload {
        let key = try keychain.getOrCreateKey(for: "backup_encryption")
        
        guard let sealedBox = try AES.GCM.SealedBox(combined: data) else {
            throw RestoreError.decryptionFailed("Invalid AES-GCM sealed box format")
        }
        
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        let decoder = JSONDecoder()
        return try decoder.decode(BackupPayload.self, from: decryptedData)
    }
}