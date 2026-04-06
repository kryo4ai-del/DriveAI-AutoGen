struct EncryptionService {
    private static let keychain = KeychainStorage()
    private static let algorithm = "AES-256-CBC"
    
    // Derive master key from device hardware (unique per device)
    static func getMasterKey() throws -> SymmetricKey {
        if let existingKey = try keychain.retrieveKey("backup-master-key") {
            return existingKey
        }
        
        // Generate new key on first call
        let newKey = SymmetricKey(size: .bits256)
        try keychain.storeKey(newKey, identifier: "backup-master-key")
        return newKey
    }
    
    // Encrypt backup JSON
    static func encrypt(_ data: Data) throws -> (ciphertext: Data, iv: Data, tag: Data) {
        let key = try getMasterKey()
        let nonce = try AES.GCM.Nonce()
        
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        
        return (
            ciphertext: sealedBox.ciphertext,
            iv: Data(nonce),
            tag: sealedBox.tag ?? Data()
        )
    }
    
    // Decrypt backup JSON
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
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        try SecItemAdd(query as CFDictionary, nil).check()
    }
    
    func retrieveKey(_ identifier: String) throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data else {
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
}