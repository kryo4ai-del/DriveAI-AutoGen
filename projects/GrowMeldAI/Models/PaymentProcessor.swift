// Features/Subscription/Domain/Services/PaymentProcessorProtocol.swift

import Foundation

protocol PaymentProcessor: Sendable {
    
    func createSubscriptionIntent(
        plan: SubscriptionPlan,
        userId: UUID
    ) async throws -> SubscriptionIntent
    
    func confirmAndCharge(
        intentId: String,
        paymentMethodToken: String,
        plan: SubscriptionPlan,
        userId: UUID,
        userEmail: String
    ) async throws -> BillingReceipt
    
    func fetchSubscriptionStatus(subscriptionId: String) async throws -> ProcessorSubscriptionStatus
    
    func chargeRenewal(
        subscriptionId: String,
        billingCycle: BillingCycle
    ) async throws -> BillingReceipt
    
    func cancelSubscription(subscriptionId: String) async throws
    
    func refund(
        subscriptionId: String,
        billingCycleId: String,
        amountEUR: Decimal,
        reason: RefundReason
    ) async throws -> RefundReceipt
    
    func fetchReceipt(receiptId: String) async throws -> ReceiptData
}

struct SubscriptionIntent: Codable, Sendable {
    let processorIntentId: String
    let clientSecret: String
    let requiresUserAction: Bool
    let createdAt: Date
}

struct ProcessorSubscriptionStatus: Codable, Sendable {
    let subscriptionId: String
    let status: String
    let nextBillingDate: Date?
    let currentPeriodEnd: Date?
    let cancelledAt: Date?
}

struct ReceiptData: Codable, Sendable {
    let receiptId: String
    let htmlUrl: String
    let pdfUrl: String
    let issuedAt: Date
}