// Services/Purchases/PurchaseValidator.swift
import Foundation
import CryptoKit

final class PurchaseValidator {
    private let keychain: KeychainStorage
    
    init(keychain: KeychainStorage = KeychainStorage()) {
        self.keychain = keychain
    }
    
    /// Validate cached purchase without network call
    func validatePurchase(_ state: PurchaseState) -> Bool {
        // 1. Check expiry (one-time purchase, but keep pattern for future subscriptions)
        if let expiryDate = state.expiryDate, expiryDate < Date.now {
            return false
        }
        
        // 2. Verify hash (detect tampering)
        guard let storedHash = getStoredHash(for: state) else {
            return false
        }
        
        let currentHash = computeHash(for: state)
        return storedHash == currentHash
    }
    
    func storeHash(for state: PurchaseState) throws {
        let hash = computeHash(for: state)
        let hashKey = "hash_\(state.featureId)"
        try keychain.store(hash.data(using: .utf8) ?? Data(), for: hashKey)
    }
    
    private func computeHash(for state: PurchaseState) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        guard let data = try? encoder.encode(state) else {
            return ""
        }
        
        let digest = SHA256.hash(data: data)
        return digest.withUnsafeBytes { buffer in
            buffer.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    private func getStoredHash(for state: PurchaseState) -> String? {
        let hashKey = "hash_\(state.featureId)"
        guard let data = try? keychain.retrieve(for: hashKey) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}