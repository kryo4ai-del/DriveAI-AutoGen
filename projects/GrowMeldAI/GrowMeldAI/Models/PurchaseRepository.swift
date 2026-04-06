@MainActor
final class PurchaseRepository: ObservableObject {
    private let logger = Logger(subsystem: "com.driveai", category: "purchases")
    
    func completePurchase(
        feature: PurchasableFeature,
        storeKitTransaction: Transaction
    ) async throws {
        // Validate transaction before persisting
        let verificationState = validateTransaction(storeKitTransaction)
        
        guard verificationState == .verified else {
            logger.warning("Rejected unverified transaction: \(storeKitTransaction.id), state: \(verificationState)")
            throw PurchaseError.receiptValidationFailed
        }
        
        let purchase = PurchaseTransaction(
            id: storeKitTransaction.id,
            featureId: feature.id,
            purchaseDate: storeKitTransaction.purchaseDate,
            expiryDate: storeKitTransaction.expirationDate,
            receiptData: encodeReceipt(storeKitTransaction),
            verificationState: verificationState
        )
        
        try await localStore.savePurchase(purchase)
        featureGate.unlockFeature(feature.id)
        await loadTransactions()
        
        logger.info("Completed verified purchase: \(purchase.id) for feature: \(feature.id)")
    }
    
    private func validateTransaction(_ transaction: Transaction) -> PurchaseTransaction.VerificationState {
        // StoreKit 2 auto-validates via VerificationResult
        // But check for revocation/upgrade status
        
        if transaction.isRevoked {
            logger.warning("Transaction revoked: \(transaction.id)")
            return .invalid
        }
        
        // Subscription-type checks (if applicable in future)
        if let expiryDate = transaction.expirationDate, Date() > expiryDate {
            logger.debug("Transaction expired: \(transaction.id)")
            return .invalid
        }
        
        return .verified
    }
    
    private func encodeReceipt(_ transaction: Transaction) -> String {
        // Store transaction data for audit/support purposes
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode([
                "id": transaction.id,
                "productID": transaction.productID,
                "purchaseDate": transaction.purchaseDate.ISO8601Format(),
                "bundleID": transaction.bundleID
            ])
            return data.base64EncodedString()
        } catch {
            logger.error("Failed to encode receipt: \(error.localizedDescription)")
            return ""
        }
    }
}