// TIER 1: Sensitive (store in Keychain, purge after verification)
import Foundation
struct SensitiveSubscriptionData {
    let receiptToken: String  // JWT from StoreKit 2 — PURGE after 24-48 hours
    let transactionID: String // Unique per purchase — RETAIN for 6+ years (tax/audit)
}

// TIER 2: User-Facing (store in UserDefaults or local JSON)

// TIER 3: Analytics (optional, requires consent)
// Struct SubscriptionEvent declared in Models/SubscriptionEvent.swift
