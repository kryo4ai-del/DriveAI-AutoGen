// BEFORE: Broken
class MockStoreKitService: StoreKitServiceProtocol {
    // Missing all methods!
}

// AFTER: Complete
actor MockStoreKitService: StoreKitServiceProtocol {
    var entitlements: Set<String> = []
    var mockProducts: [DriveAIProduct] = []
    var shouldThrowError: Error?
    var fetchCallCount = 0
    var purchaseCallCount = 0
    
    var lastPurchasedProductID: String?
    var lastRestoreCallDate: Date?
    
    func fetchProducts(forceRefresh: Bool = false) async throws -> [DriveAIProduct] {
        fetchCallCount += 1
        if let error = shouldThrowError { throw error }
        return mockProducts
    }
    
    func purchase(productID: String) async throws -> VerifiedTransaction {
        purchaseCallCount += 1
        lastPurchasedProductID = productID
        
        if let error = shouldThrowError { throw error }
        
        guard !entitlements.contains(productID) else {
            throw StoreKitError.alreadyPurchased(productID)
        }
        
        entitlements.insert(productID)
        return MockVerifiedTransaction(productID: productID)
    }
    
    func restorePurchases() async throws -> Set<String> {
        lastRestoreCallDate = Date()
        if let error = shouldThrowError { throw error }
        return entitlements
    }
    
    func getEntitlements() -> Set<String> {
        entitlements
    }
}