import Foundation

struct CachedProduct: Codable {
    let id: String
    let displayName: String
    let price: Double
    let displayPrice: String
}

class IAPStorage {
    private let userDefaults = UserDefaults.standard

    private enum Keys {
        static let cachedProducts = "com.growmeldai.iap.cachedProducts"
        static let cachedPremiumStatus = "com.growmeldai.iap.cachedPremiumStatus"
        static let cachedExpirationDate = "com.growmeldai.iap.cachedExpirationDate"
    }

    func getCachedProducts() -> [CachedProduct]? {
        guard let data = userDefaults.data(forKey: Keys.cachedProducts) else {
            return nil
        }
        return try? JSONDecoder().decode([CachedProduct].self, from: data)
    }

    func setCachedProducts(_ products: [CachedProduct]) {
        if let data = try? JSONEncoder().encode(products) {
            userDefaults.set(data, forKey: Keys.cachedProducts)
        }
    }

    func setCachedSubscriptionStatus(isPremium: Bool, expirationDate: Date?) {
        userDefaults.set(isPremium, forKey: Keys.cachedPremiumStatus)
        if let expiration = expirationDate {
            userDefaults.set(expiration, forKey: Keys.cachedExpirationDate)
        }
    }

    func getCachedSubscriptionStatus() -> (isPremium: Bool, expirationDate: Date?) {
        let isPremium = userDefaults.bool(forKey: Keys.cachedPremiumStatus)
        let expirationDate = userDefaults.object(forKey: Keys.cachedExpirationDate) as? Date
        return (isPremium, expirationDate)
    }
}