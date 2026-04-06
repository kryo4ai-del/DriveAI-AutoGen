// Use StoreKit 2 proper types
import StoreKit

// Don't create custom enum; use Transaction.VerificationResult
enum TransactionVerification {
    case verified(transaction: VerificationResult<Transaction>)
    case unverified(transaction: VerificationResult<Transaction>)
}