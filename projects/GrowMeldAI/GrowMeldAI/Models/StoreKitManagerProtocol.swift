protocol StoreKitManagerProtocol {
    var availableProducts: [Product] { get }
    var purchasedProductIDs: Set<String> { get }
    func purchase(product: Product) async -> Bool
    func restorePurchases() async
}

extension StoreKitManager: StoreKitManagerProtocol {}

// For testing:
class MockStoreKitManager: StoreKitManagerProtocol {
    var availableProducts: [Product] = []
    var purchasedProductIDs: Set<String> = []
    
    func purchase(product: Product) async -> Bool {
        purchasedProductIDs.insert(product.id)
        return true
    }
    
    func restorePurchases() async {}
}