class EntitlementChecker {
    // Use cached entitlements for UX (instant loading)
    // But verify on server before granting premium features
    
    func canAccessPremiumFeature() async -> Bool {
        // 1. Check cached entitlements (instant)
        if let cached = localCache.getCachedEntitlements(),
           cached.contains(where: { $0.type == .premiumFeatures }) {
            return true  // Show feature immediately
        }
        
        // 2. Verify with server in background
        let fresh = await subscriptionManager.verifyEntitlements()
        return fresh.contains(where: { $0.type == .premiumFeatures })
    }
}