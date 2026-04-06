// MARK: - Purchase Processing

enum PurchaseResult {
    case success(transactionID: String)
    case failed(PurchaseError)
    case pending
    case cancelled
}

func purchase(product: Product) async -> PurchaseResult {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let storeResult = try await product.purchase()
        
        switch storeResult {
        case .success(let verification):
            return await processPurchaseTransaction(verification, productID: product.id)
            
        case .userCancelled:
            return .cancelled
            
        case .pending:
            // Family sharing or parental approval pending
            return .pending
            
        @unknown default:
            return .failed(.unknown(NSError(domain: "StoreKit", code: -1)))
        }
    } catch {
        lastError = error
        return .failed(.unknown(error))
    }
}

private func processPurchaseTransaction(
    _ verification: VerificationResult<Transaction>,
    productID: String
) async -> PurchaseResult {
    do {
        let transaction = try checkVerified(verification)
        
        // ✅ CRITICAL: Finish transaction and wait for confirmation
        await transaction.finish()
        
        // ✅ CRITICAL: Wait for entitlement to propagate
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // ✅ CRITICAL: Refresh and verify entitlement exists
        await updatePurchasedProducts()
        
        // Verify purchase actually went through
        if purchasedProductIDs.contains(productID) {
            return .success(transactionID: transaction.id.description)
        } else {
            // Transaction finished but entitlement not yet visible
            // This can happen on slow networks; let transaction listener handle it
            return .failed(.transactionNotConfirmed)
        }
    } catch {
        return .failed(.verificationFailed(error))
    }
}