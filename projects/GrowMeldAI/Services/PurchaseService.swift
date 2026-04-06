import Foundation
import StoreKit

@MainActor
protocol PurchaseService: AnyObject, Sendable {
    /// Fetch available one-time purchase products from App Store
    func fetchProducts() async throws -> [PurchaseProduct]
    
    /// Initiate a purchase for a specific product
    func purchase(productId: String) async throws -> PurchaseTransaction
    
    /// Restore all previous purchases
    func restorePurchases() async throws -> [PurchaseTransaction]
    
    /// Check if a specific feature is unlocked
    func checkPurchaseStatus(for feature: UnlockableFeature) async throws -> Bool
    
    /// Stream of background transaction updates
    var transactionUpdates: AsyncStream<PurchaseTransaction> { get }
}