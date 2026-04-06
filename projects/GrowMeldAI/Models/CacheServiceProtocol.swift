import Foundation

struct DriveAIProductModel: Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
}

protocol CacheServiceProtocol {
    func cache(_ products: [DriveAIProductModel], ttl: TimeInterval)
    func getCached() -> [DriveAIProductModel]?
    func isExpired() -> Bool
}

class UserDefaultsCacheService: CacheServiceProtocol {
    private let ttlKey = "products_cache_ttl"
    private let cacheKey = "cached_products"

    func cache(_ products: [DriveAIProductModel], ttl: TimeInterval) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(products) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
        UserDefaults.standard.set(Date().addingTimeInterval(ttl), forKey: ttlKey)
    }

    func getCached() -> [DriveAIProductModel]? {
        guard !isExpired() else { return nil }
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode([DriveAIProductModel].self, from: data)
    }

    func isExpired() -> Bool {
        guard let expiry = UserDefaults.standard.object(forKey: ttlKey) as? Date else {
            return true
        }
        return Date() > expiry
    }
}