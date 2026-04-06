// ✅ GOOD: Validate before granting access
@MainActor
final class TransactionValidator {
    func validateAndGrant(_ verificationResult: VerificationResult<Transaction>) 
        async throws -> Transaction {
        
        let transaction = try verificationResult.unsafePayloadIfValid
        
        // Verify JWS signature (Apple-signed)
        guard transaction.originalTransactionID != nil else {
            throw IAPError.invalidTransaction
        }
        
        // Check expiration
        guard !isExpired(transaction) else {
            throw IAPError.transactionExpired
        }
        
        // Persist to local database
        try await persistTransaction(transaction)
        
        return transaction
    }
}

// ❌ AVOID: Trusting StoreKit2 transactions without validation
// StoreKit2 *does* validate signatures, but explicit validation is defensive