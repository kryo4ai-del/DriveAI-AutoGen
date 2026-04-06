// Store transaction reference for safe finalization
@MainActor
final class StoreKit2PurchaseService: PurchaseService {
    private var transactionsToFinish: [UInt64] = []
    
    private func handleVerification(
        _ verification: VerificationResult<StoreKit.Transaction>,
        feature: UnlockableFeature?
    ) async throws -> PurchaseTransaction {
        let transaction = try verification.payloadValue
        
        // ... create purchaseTransaction ...
        
        // MUST finish AFTER persistence succeeds
        try await repository.saveTransaction(purchaseTransaction)
        await transaction.finish() // ← CRITICAL
        
        return purchaseTransaction
    }
}