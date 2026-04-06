import Foundation

final class IAPStorage {
    static let shared = IAPStorage()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.driveai.iap")!
    
    private enum Keys {
        static let lastPurchaseDate = "iap.lastPurchaseDate"
        static let purchasedProductIds = "iap.purchasedProductIds"
        static let cachedPremiumStatus = "iap.isPremium"
    }
    
    // MARK: - Cache Management
    
    func savePurchase(productId: String) {
        var productIds = userDefaults.stringArray(forKey: Keys.purchasedProductIds) ?? []
        if !productIds.contains(productId) {
            productIds.append(productId)
            userDefaults.set(productIds, forKey: Keys.purchasedProductIds)
        }
        
        userDefaults.set(Date(), forKey: Keys.lastPurchaseDate)
    }
    
    func getPurchasedProductIds() -> [String] {
        return userDefaults.stringArray(forKey: Keys.purchasedProductIds) ?? []
    }
    
    func getLastPurchaseDate() -> Date? {
        return userDefaults.object(forKey: Keys.lastPurchaseDate) as? Date
    }
    
    func cachePremiumStatus(_ isPremium: Bool) {
        userDefaults.set(isPremium, forKey: Keys.cachedPremiumStatus)
    }
    
    func getCachedPremiumStatus() -> Bool {
        return userDefaults.bool(forKey: Keys.cachedPremiumStatus)
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: Keys.purchasedProductIds)
        userDefaults.removeObject(forKey: Keys.lastPurchaseDate)
        userDefaults.removeObject(forKey: Keys.cachedPremiumStatus)
    }
}