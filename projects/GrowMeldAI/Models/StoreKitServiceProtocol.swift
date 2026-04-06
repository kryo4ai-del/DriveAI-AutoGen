// Sources/Services/StoreKitServiceProtocol.swift

import StoreKit

/// Abstracts StoreKit 2 operations for testability
protocol StoreKitServiceProtocol: Actor, Sendable {
    /// Current set of owned product IDs
    var entitlements: Set<String> { get }
    
    /// Fetch available products from App Store
    func fetchProducts(forceRefresh: Bool) async throws -> [DriveAIProduct]
    
    /// Initiate purchase for a product
    func purchase(productID: String) async throws -> VerifiedTransaction
    
    /// Restore previous purchases from this user's account
    func restorePurchases() async throws -> Set<String>
    
    /// Get current entitlements without network call
    func getEntitlements() -> Set<String>
}

// Sources/Services/CacheServiceProtocol.swift
