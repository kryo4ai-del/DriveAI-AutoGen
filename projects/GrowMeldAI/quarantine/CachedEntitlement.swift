// ❌ RISKY: Cache forever
let cachedExpiry = UserDefaults.standard.object(forKey: "subscriptionExpiry") as? Date

// ✅ SAFER: Cache with TTL + refresh
struct CachedEntitlement {
    let tier: SubscriptionTier
    let expiryDate: Date
    let cachedAt: Date
    
    var isStale: Bool {
        Date().timeIntervalSince(cachedAt) > 3600 // 1-hour TTL
    }
}

// ✅ SAFEST: Refresh immediately on foreground
.task {
    await subscriptionViewModel.refreshSubscriptionStatus()
}