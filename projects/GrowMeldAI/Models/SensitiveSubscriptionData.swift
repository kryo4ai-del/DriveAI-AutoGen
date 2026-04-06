// TIER 1: Sensitive (store in Keychain, purge after verification)
struct SensitiveSubscriptionData {
    let receiptToken: String  // JWT from StoreKit 2 — PURGE after 24-48 hours
    let transactionID: String // Unique per purchase — RETAIN for 6+ years (tax/audit)
}

// TIER 2: User-Facing (store in UserDefaults or local JSON)

// TIER 3: Analytics (optional, requires consent)
struct SubscriptionEvent: Codable {
    let eventType: String         // "trial_started", "purchase_completed", "subscription_expired"
    let timestamp: Date
    let productID: String
    // NO user identifiers (only local device tracking)
}