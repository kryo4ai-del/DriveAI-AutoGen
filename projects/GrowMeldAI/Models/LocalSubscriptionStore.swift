// Features/Subscription/Data/SubscriptionStoreProtocol.swift

protocol LocalSubscriptionStore: Sendable {
    // Subscriptions
    func saveSubscription(_ subscription: UserSubscription) async throws
    func fetchSubscription(_ id: UUID) async throws -> UserSubscription?
    func fetchSubscriptionsForUser(_ userId: UUID) async throws -> [UserSubscription]
    
    // Billing Cycles
    func saveBillingCycle(_ cycle: BillingCycle) async throws
    func fetchBillingCycle(_ id: UUID) async throws -> BillingCycle?
    func fetchBillingCyclesForSubscription(_ subscriptionId: UUID) async throws -> [BillingCycle]
    
    // Receipts & Invoices
    func saveReceipt(_ receipt: BillingReceipt) async throws
    func fetchReceipt(_ id: UUID) async throws -> BillingReceipt?
    func saveRefundReceipt(_ receipt: RefundReceipt) async throws
    
    // Compliance
    func saveConsentRecord(_ record: ConsentRecord) async throws
    func fetchConsentRecords(userId: UUID, type: ConsentType) async throws -> [ConsentRecord]
    func updateConsentRevoked(userId: UUID, type: ConsentType, revokedAt: Date) async throws
    
    // Data Retention
    func deletePaymentTokensBefore(_ date: Date) async throws
    func deletePaymentDataForUser(_ userId: UUID) async throws
    func deleteConsentRecordsForUser(_ userId: UUID) async throws
    func anonymizeSubscriptionRecordsForUser(_ userId: UUID) async throws
    
    // Audit Trail
    func recordComplianceAction(userId: UUID, action: String, timestamp: Date) async throws
    func recordWithdrawalAudit(subscriptionId: UUID, userId: UUID, timestamp: Date, reason: String?) async throws
}