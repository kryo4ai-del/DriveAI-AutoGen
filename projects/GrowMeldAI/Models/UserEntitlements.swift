// ✅ GOOD: Persistent storage via SQLite
struct UserEntitlements: Codable {
    let userId: String
    var premiumFeatures: Set<String> = []
    var subscriptionStatus: SubscriptionStatus?
    var lastValidatedAt: Date?
}

// Services/LocalDataService.swift (existing from project context)

// ❌ AVOID: UserDefaults for entitlements
// - Can be cleared by iOS when storage is low
// - User loses access to purchased features after reinstall