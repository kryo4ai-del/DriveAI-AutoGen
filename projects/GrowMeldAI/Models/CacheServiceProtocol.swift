import Foundation

protocol CacheServiceProtocol {
    func cache(_ products: [DriveAIProduct], ttl: TimeInterval)
    func getCached() -> [DriveAIProduct]?
    func isExpired() -> Bool
}

class UserDefaultsCacheService: CacheServiceProtocol {
    private let ttlKey = "products_cache_ttl"
    private let productsKey = "cached_products"

    func cache(_ products: [DriveAIProduct], ttl: TimeInterval = 3600) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(products) {
            UserDefaults.standard.set(data, forKey: productsKey)
        }
        let expiry = Date().addingTimeInterval(ttl)
        UserDefaults.standard.set(expiry, forKey: ttlKey)
    }

    func getCached() -> [DriveAIProduct]? {
        guard !isExpired() else { return nil }
        guard let data = UserDefaults.standard.data(forKey: productsKey) else { return nil }
        return try? JSONDecoder().decode([DriveAIProduct].self, from: data)
    }

    func isExpired() -> Bool {
        guard let expiry = UserDefaults.standard.object(forKey: ttlKey) as? Date else {
            return true
        }
        return Date() > expiry
    }
}