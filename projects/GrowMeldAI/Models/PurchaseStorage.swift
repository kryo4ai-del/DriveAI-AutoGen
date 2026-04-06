// Option 1: Auto-store in PurchaseStorage
class PurchaseStorage {
    private let purchaseValidator: PurchaseValidator
    
    func savePurchase(_ transaction: StoreKit.Transaction) throws {
        let state = PurchaseState(...)
        let encoded = try JSONEncoder().encode(state)
        try keychain.store(encoded, for: keychainKeyPrefix + feature.rawValue)
        
        // ✅ NEW: Automatically store hash after saving
        try purchaseValidator.storeHash(for: state)
        
        // ... rest
    }
}

// Option 2: Make validatePurchase() create hash if missing
extension PurchaseValidator {
    func validatePurchase(_ state: PurchaseState, autoStoreIfMissing: Bool = true) -> Bool {
        if let storedHash = getStoredHash(for: state) {
            let currentHash = computeHash(for: state)
            return storedHash == currentHash
        }
        
        if autoStoreIfMissing {
            try? storeHash(for: state)
            return true  // Trust first time
        }
        
        return false
    }
}