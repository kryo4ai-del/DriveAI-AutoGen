class MockStoreKit2Service: StoreKitServiceProtocol {
    var stubbedProducts: [StoreProduct] = []
    var stubbedError: StoreKitError?
    var stubbedPurchaseResult: PurchaseResult = .success
    var stubbedSubscriptionStatus: SubscriptionStatus = .free
    var delayedPurchaseCompletion: TimeInterval = 0
    
    var fetchProductsCalled = false
    var purchaseCalled = false
    var restorePurchasesCalled = false
    
    func fetchProducts(for ids: [String]) async throws -> [StoreProduct] {
        fetchProductsCalled = true
        if let error = stubbedError { throw error }
        return stubbedProducts
    }
    
    func purchase(_ product: StoreProduct) async -> PurchaseResult {
        purchaseCalled = true
        if delayedPurchaseCompletion > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delayedPurchaseCompletion * 1_000_000_000))
        }
        return stubbedPurchaseResult
    }
    
    func restorePurchases() async -> SubscriptionStatus {
        restorePurchasesCalled = true
        return stubbedSubscriptionStatus
    }
}