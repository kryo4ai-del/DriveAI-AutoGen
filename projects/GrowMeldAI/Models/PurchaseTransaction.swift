import Foundation
import StoreKit

struct PurchaseTransaction: Identifiable, Codable, Hashable {
    let id: String
    let productId: String
    let feature: UnlockableFeature
    let purchaseDate: Date
    let expirationDate: Date?
    let isValid: Bool
    let jwsRepresentation: String?
    let bundleId: String
    let appVersion: String
    
    enum CodingKeys: String, CodingKey {
        case id, productId, feature, purchaseDate
        case expirationDate, isValid, jwsRepresentation
        case bundleId, appVersion
    }
    
    /// Safe initializer with validation
    init(
        id: String,
        productId: String,
        feature: UnlockableFeature,
        purchaseDate: Date,
        expirationDate: Date? = nil,
        isValid: Bool = true,
        jwsRepresentation: String? = nil,
        bundleId: String = Bundle.main.bundleIdentifier ?? "unknown",
        appVersion: String = Bundle.main.appVersion ?? "unknown"
    ) {
        self.id = id
        self.productId = productId
        self.feature = feature
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.isValid = isValid
        self.jwsRepresentation = jwsRepresentation
        self.bundleId = bundleId
        self.appVersion = appVersion
    }
    
    /// Create from StoreKit transaction with validation
    @available(iOS 17.0, *)
    init?(from transaction: StoreKit.Transaction, feature: UnlockableFeature) {
        // VALIDATION: Must be valid
        guard transaction.isValid else {
            print("⚠️ Rejected invalid transaction: \(transaction.id)")
            return nil
        }
        
        // VALIDATION: Product ID must match expected feature
        guard transaction.productID == feature.appStoreProductId else {
            print("⚠️ Rejected transaction for wrong feature: expected \(feature.appStoreProductId), got \(transaction.productID)")
            return nil
        }
        
        self.id = String(transaction.id)
        self.productId = transaction.productID
        self.feature = feature
        self.purchaseDate = transaction.purchaseDate
        self.expirationDate = transaction.expirationDate
        self.isValid = true // Enforce to true after validation
        self.jwsRepresentation = transaction.jwsRepresentation
        self.bundleId = Bundle.main.bundleIdentifier ?? "unknown"
        self.appVersion = Bundle.main.appVersion ?? "unknown"
    }
    
    /// Whether transaction is still active (not expired)
    var isActive: Bool {
        guard isValid else { return false }
        if let expiration = expirationDate {
            return Date() < expiration
        }
        return true // One-time purchases never expire
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}