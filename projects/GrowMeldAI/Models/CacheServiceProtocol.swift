protocol CacheServiceProtocol {
    func cache(_ products: [DriveAIProduct], ttl: TimeInterval)
    func getCached() -> [DriveAIProduct]?
    func isExpired() -> Bool
}

class UserDefaultsCacheService: CacheServiceProtocol {
    private let ttlKey = "products_cache_ttl"
    
    func cache(_ products: [DriveAIProduct], ttl: TimeInterval = 3600) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(products)
        UserDefaults.standard.set(data, forKey: "cached_products")
        UserDefaults.standard.set(Date().addingTimeInterval(ttl), forKey: ttlKey)
    }
    
    func isExpired() -> Bool {
        guard let expiry = UserDefaults.standard.object(forKey: ttlKey) as? Date else {
            return true
        }
        return Date() > expiry
    }
}