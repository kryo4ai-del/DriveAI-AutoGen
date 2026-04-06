// Features/Subscription/Domain/Models/Withdrawal.swift

import Foundation

/// Represents the user's 14-day withdrawal right under DACH consumer protection laws.
/// CRITICAL: This must be enforced by the app.
struct WithdrawalRight {
    let subscriptionId: UUID
    let purchaseDate: Date
    let withdrawalDeadline: Date               // purchaseDate + 14 days
    let isWithdrawn: Bool
    let withdrawalRequestedAt: Date?
    let processedAt: Date?                     // When refund was issued
    let refundedAmountEUR: Decimal?
    let refundProcessorTransactionId: String?
    
    /// True if user is still within 14-day withdrawal period
    var isWithinWithdrawalPeriod: Bool {
        Date() <= withdrawalDeadline && !isWithdrawn
    }
    
    /// True if user has requested withdrawal but it hasn't been processed
    var isPending: Bool {
        withdrawalRequestedAt != nil && processedAt == nil
    }
}