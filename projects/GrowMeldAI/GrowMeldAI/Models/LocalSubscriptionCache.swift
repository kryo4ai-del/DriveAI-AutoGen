class LocalSubscriptionCache {
    private let defaults = UserDefaults.standard
    private let keychain = KeychainService.shared
    
    // Cache entitlements locally with TTL
    func cacheEntitlements(_ entitlements: [Entitlement], ttl: TimeInterval = 7 * 24 * 3600) {
        let expiryDate = Date().addingTimeInterval(ttl)
        let cached = CachedEntitlements(
            entitlements: entitlements,
            cachedAt: Date(),
            expiresAt: expiryDate
        )
        defaults.set(try? JSONEncoder().encode(cached), forKey: "cached_entitlements")
    }
    
    // Return cached entitlements if valid
    func getCachedEntitlements() -> [Entitlement]? {
        guard let data = defaults.data(forKey: "cached_entitlements"),
              let cached = try? JSONDecoder().decode(CachedEntitlements.self, from: data),
              cached.expiresAt > Date() else {
            return nil
        }
        return cached.entitlements
    }
    
    // Verify entitlements on next network connection
    func syncEntitlements(when isOnline: Bool) async {
        guard isOnline else { return }
        // Fetch fresh entitlements from StoreKit 2
        let fresh = await subscriptionManager.verifyEntitlements()
        cacheEntitlements(fresh)
    }
}