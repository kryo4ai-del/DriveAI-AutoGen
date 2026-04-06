struct CachedProduct: Codable {
    let id: String
    let displayName: String
    let price: Decimal
    let displayPrice: String
}

// Add to IAPStorage
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

// Cache subscription status for offline
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
