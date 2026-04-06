import Foundation

protocol CacheServiceProtocol {
    func cache(_ products: [DriveAIProduct], ttl: TimeInterval)
    func getCached() -> [DriveAIProduct]?
    func isExpired() -> Bool
}

class UserDefaultsCacheService: CacheServiceProtocol {
    private let ttlKey = "products_cache_ttl"
    private let cacheKey = "cached_products"

    func cache(_ products: [DriveAIProduct], ttl: TimeInterval = 3600) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(products) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
        let expiry = Date().addingTimeInterval(ttl)
        UserDefaults.standard.set(expiry, forKey: ttlKey)
    }

    func getCached() -> [DriveAIProduct]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode([DriveAIProduct].self, from: data)
    }

    func isExpired() -> Bool {
        guard let expiry = UserDefaults.standard.object(forKey: ttlKey) as? Date else {
            return true
        }
        return Date() > expiry
    }
}