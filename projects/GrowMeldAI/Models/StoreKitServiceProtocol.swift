import Foundation
import StoreKit

struct DriveAIProduct: Sendable {
    let id: String
    let displayName: String
    let description: String
    let displayPrice: String
    let price: Decimal
}

struct VerifiedTransaction: Sendable {
    let productID: String
    let transactionID: UInt64
    let purchaseDate: Date
}

protocol StoreKitServiceProtocol: AnyObject, Sendable {
    var entitlements: Set<String> { get }

    func fetchProducts(forceRefresh: Bool) async throws -> [DriveAIProduct]
    func purchase(productID: String) async throws -> VerifiedTransaction
    func restorePurchases() async throws -> Set<String>
    func getEntitlements() -> Set<String>
}