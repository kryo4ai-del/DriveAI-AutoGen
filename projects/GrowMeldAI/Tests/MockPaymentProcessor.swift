// Features/Subscription/Processors/MockPaymentProcessor.swift

import Foundation

final class MockPaymentProcessor: PaymentProcessor {
    
    var simulatePaymentFailure = false
    var simulateNetworkError = false
    var delayMilliseconds: UInt64 = 100
    
    private var subscriptions: [String: ProcessorSubscriptionStatus] = [:]
    private let lock = NSLock()
    
    func createSubscriptionIntent(
        plan: SubscriptionPlan,
        userId: UUID
    ) async throws -> SubscriptionIntent {
        if simulateNetworkError {
            throw PaymentProcessorError.networkUnavailable
        }
        
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        
        return SubscriptionIntent(
            processorIntentId: "mock_intent_\(UUID().uuidString.prefix(8))",
            clientSecret: "mock_secret_\(UUID().uuidString.prefix(8))",
            requiresUserAction: false,
            createdAt: .now
        )
    }
    
    func confirmAndCharge(
        intentId: String,
        paymentMethodToken: String,
        plan: SubscriptionPlan,
        userId: UUID,
        userEmail: String
    ) async throws -> BillingReceipt {
        if simulateNetworkError {
            throw PaymentProcessorError.networkUnavailable
        }
        
        if simulatePaymentFailure {
            throw PaymentProcessorError.cardDeclined
        }
        
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        
        let subscriptionId = "mock_sub_\(UUID().uuidString.prefix(8))"
        let renewalDate = Calendar.current.date(byAdding: .month, value: plan.durationMonths, to: .now) ?? .now
        
        lock.lock()
        subscriptions[subscriptionId] = ProcessorSubscriptionStatus(
            subscriptionId: subscriptionId,
            status: "active",
            nextBillingDate: renewalDate,
            currentPeriodEnd: renewalDate,
            cancelledAt: nil
        )
        lock.unlock()
        
        let vatAmount = plan.pricePerCycleEUR * (plan.vatRatePercent / 100)
        
        return BillingReceipt(
            receiptId: UUID(),
            processorReceiptId: "mock_receipt_\(UUID().uuidString.prefix(8))",
            chargeAmount: plan.priceGrossEUR,
            currency: "EUR",
            vatAmount: vatAmount,
            vatRate: plan.vatRatePercent,
            issuedAt: .now,
            downloadUrl: "https://mock.example.com/receipt/mock_receipt"
        )
    }
    
    func fetchSubscriptionStatus(subscriptionId: String) async throws -> ProcessorSubscriptionStatus {
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        
        lock.lock()
        defer { lock.unlock() }
        
        guard let status = subscriptions[subscriptionId] else {
            throw PaymentProcessorError.processorError("Subscription not found")
        }
        
        return status
    }
    
    func chargeRenewal(
        subscriptionId: String,
        billingCycle: BillingCycle
    ) async throws -> BillingReceipt {
        if simulatePaymentFailure {
            throw PaymentProcessorError.cardDeclined
        }
        
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        
        return BillingReceipt(
            receiptId: UUID(),
            processorReceiptId: "mock_renewal_\(UUID().uuidString.prefix(8))",
            chargeAmount: billingCycle.amountChargedEUR,
            currency: billingCycle.currencyCode,
            vatAmount: billingCycle.vatAmountEUR,
            vatRate: (billingCycle.vatAmountEUR / billingCycle.amountChargedEUR) * 100,
            issuedAt: .now,
            downloadUrl: nil
        )
    }
    
    func cancelSubscription(subscriptionId: String) async throws {
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        
        lock.lock()
        if var status = subscriptions[subscriptionId] {
            status.cancelledAt = .now
            subscriptions[subscriptionId] = status
        }
        lock.unlock()
    }
    
    func refund(
        subscriptionId: String,
        billingCycleId: String,
        amountEUR: Decimal,
        reason: RefundReason
    ) async throws -> RefundReceipt {
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        
        return RefundReceipt(
            refundId: UUID(),
            processorRefundId: "mock_refund_\(UUID().uuidString.prefix(8))",
            amountRefunded: amountEUR,
            reason: reason,
            processedAt: .now
        )
    }
    
    func fetchReceipt(receiptId: String) async throws -> ReceiptData {
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        
        return ReceiptData(
            receiptId: receiptId,
            htmlUrl: "https://mock.example.com/receipts/\(receiptId).html",
            pdfUrl: "https://mock.example.com/receipts/\(receiptId).pdf",
            issuedAt: .now
        )
    }
}