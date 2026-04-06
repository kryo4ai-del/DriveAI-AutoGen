import Foundation
import CryptoKit

// MARK: - Supporting Types

struct ConsentToken: Codable {
    let id: String
    let userId: String
    let scope: String
    let issuedAt: Date
    let expiresAt: Date?
    let granted: Bool

    init(
        id: String = UUID().uuidString,
        userId: String,
        scope: String,
        issuedAt: Date = Date(),
        expiresAt: Date? = nil,
        granted: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.scope = scope
        self.issuedAt = issuedAt
        self.expiresAt = expiresAt
        self.granted = granted
    }
}

struct EncryptedToken {
    let encryptedData: Data
    let nonce: AES.GCM.Nonce
    let tag: Data
}

// MARK: - Encryption

struct ConsentTokenEncryption {

    /// A per-process symmetric key used for sealing/opening tokens.
    /// In production this should be loaded from the Keychain.
    private static let masterKey: SymmetricKey = SymmetricKey(size: .bits256)

    static func encrypt(_ token: ConsentToken) throws -> EncryptedToken {
        let jsonData = try JSONEncoder().encode(token)
        let sealedBox = try AES.GCM.seal(jsonData, using: masterKey)
        return EncryptedToken(
            encryptedData: sealedBox.ciphertext,
            nonce: sealedBox.nonce,
            tag: sealedBox.tag
        )
    }

    static func decrypt(_ encrypted: EncryptedToken) throws -> ConsentToken {
        let sealedBox = try AES.GCM.SealedBox(
            nonce: encrypted.nonce,
            ciphertext: encrypted.encryptedData,
            tag: encrypted.tag
        )
        let jsonData = try AES.GCM.open(sealedBox, using: masterKey)
        return try JSONDecoder().decode(ConsentToken.self, from: jsonData)
    }
}