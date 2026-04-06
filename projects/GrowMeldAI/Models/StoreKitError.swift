func purchase(product: Product) async -> Result<Bool, StoreKitError> {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // ✅ CRITICAL: Wait for transaction to finish
            // Don't return until we're sure StoreKit has recorded it
            do {
                await transaction.finish()
                
                // ✅ CRITICAL: Force refresh + wait for state update
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5s grace
                await updatePurchasedProducts()
                
                // ✅ Verify purchase actually went through
                if purchasedProductIDs.contains(product.id) {
                    print("✅ Purchase confirmed: \(product.id)")
                    return .success(true)
                } else {
                    print("❌ Purchase completed but not in entitlements")
                    return .failure(.purchaseNotConfirmed)
                }
            } catch {
                // If finish() fails, transaction is still pending
                print("⚠️ Transaction finish pending (will retry in background)")
                // Let transaction listener handle it
                return .failure(.transactionPending)
            }
            
        case .userCancelled:
            return .failure(.userCancelled)
            
        case .pending:
            print("ℹ️ Purchase pending (family sharing / parental approval)")
            // Don't fail — transaction may complete later
            return .failure(.purchaseApprovalPending)
            
        @unknown default:
            return .failure(.unknown)
        }
    } catch {
        lastError = error
        print("❌ Purchase failed: \(error)")
        return .failure(.purchaseFailed(error))
    }
}

enum StoreKitError: LocalizedError {
    case purchaseNotConfirmed
    case transactionPending
    case purchaseApprovalPending
    case userCancelled
    case purchaseFailed(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .purchaseNotConfirmed:
            return "Einkauf bestätigt, aber nicht aktiviert. Bitte versuchen Sie es später."
        case .transactionPending:
            return "Einkauf wird verarbeitet. Dies kann einige Minuten dauern."
        case .purchaseApprovalPending:
            return "Genehmigung erforderlich. Bitte überprüfen Sie Ihr Apple ID-Konto."
        case .userCancelled:
            return "Einkauf abgebrochen."
        case .purchaseFailed(let error):
            return "Einkauf fehlgeschlagen: \(error.localizedDescription)"
        case .unknown:
            return "Unbekannter Fehler."
        }
    }
}