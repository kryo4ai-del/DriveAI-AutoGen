import Foundation

// MARK: - Supporting Types

enum PaymentProcessorError: Error, LocalizedError {
    case networkUnavailable
    case cardDeclined
    case subscriptionNotFound(String)
    case processorError(String)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network unavailable"
        case .cardDeclined:
            return "Card declined"
        case .subscriptionNotFound(let id):
            return "Subscription not found: \(id)"
        case .processorError(let msg):
            return "Processor error: \(msg)"
        }
    }
}

struct SubscriptionIntent {
    let processorIntentId: String
    let clientSecret: String
    let requiresUserAction: Bool
    let createdAt: Date
}

struct BillingReceipt {
    let receiptId: UUID
    let processorReceiptId: String
    let chargeAmount: Double
    let currency: String
    let vatAmount: Double
    let vatRate: Double
    let issuedAt: Date
    let downloadUrl: String?
}

struct ProcessorSubscriptionStatus {
    let subscriptionId: String
    let status: String
    let nextBillingDate: Date
    let currentPeriodEnd: Date
    var cancelledAt: Date?
}

struct BillingCycle {
    let amountCharged: Double
    let currency: String
    let vatAmount: Double
}

protocol SubscriptionPlan {
    var durationMonths: Int { get }
    var pricePerCycle: Double { get }
    var vatRatePercent: Double { get }
    var priceGross: Double { get }
}

protocol PaymentProcessor {
    func createSubscriptionIntent(plan: any SubscriptionPlan, userId: UUID) async throws -> SubscriptionIntent
    func confirmAndCharge(intentId: String, paymentMethodToken: String, plan: any SubscriptionPlan, userId: UUID, userEmail: String) async throws -> BillingReceipt
    func fetchSubscriptionStatus(subscriptionId: String) async throws -> ProcessorSubscriptionStatus
    func chargeRenewal(subscriptionId: String, billingCycle: BillingCycle) async throws -> BillingReceipt
    func cancelSubscription(subscriptionId: String) async throws
    func reactivateSubscription(subscriptionId: String) async throws -> ProcessorSubscriptionStatus
}

// MARK: - MockPaymentProcessor

final class MockPaymentProcessor: PaymentProcessor {

    var simulatePaymentFailure = false
    var simulateNetworkError = false
    var delayMilliseconds: UInt64 = 100

    private var subscriptions: [String: ProcessorSubscriptionStatus] = [:]
    private let lock = NSLock()

    func createSubscriptionIntent(
        plan: any SubscriptionPlan,
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
            createdAt: Date()
        )
    }

    func confirmAndCharge(
        intentId: String,
        paymentMethodToken: String,
        plan: any SubscriptionPlan,
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
        let renewalDate = Calendar.current.date(byAdding: .month, value: plan.durationMonths, to: Date()) ?? Date()

        lock.lock()
        subscriptions[subscriptionId] = ProcessorSubscriptionStatus(
            subscriptionId: subscriptionId,
            status: "active",
            nextBillingDate: renewalDate,
            currentPeriodEnd: renewalDate,
            cancelledAt: nil
        )
        lock.unlock()

        let vatAmount = plan.pricePerCycle * (plan.vatRatePercent / 100)

        return BillingReceipt(
            receiptId: UUID(),
            processorReceiptId: "mock_receipt_\(UUID().uuidString.prefix(8))",
            chargeAmount: plan.priceGross,
            currency: "EUR",
            vatAmount: vatAmount,
            vatRate: plan.vatRatePercent,
            issuedAt: Date(),
            downloadUrl: "https://mock.example.com/receipt/mock_receipt"
        )
    }

    func fetchSubscriptionStatus(subscriptionId: String) async throws -> ProcessorSubscriptionStatus {
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)

        lock.lock()
        defer { lock.unlock() }

        guard let status = subscriptions[subscriptionId] else {
            throw PaymentProcessorError.subscriptionNotFound(subscriptionId)
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

        let vatRate = billingCycle.amountCharged > 0
            ? (billingCycle.vatAmount / billingCycle.amountCharged) * 100
            : 0.0

        return BillingReceipt(
            receiptId: UUID(),
            processorReceiptId: "mock_renewal_\(UUID().uuidString.prefix(8))",
            chargeAmount: billingCycle.amountCharged,
            currency: billingCycle.currency,
            vatAmount: billingCycle.vatAmount,
            vatRate: vatRate,
            issuedAt: Date(),
            downloadUrl: nil
        )
    }

    func cancelSubscription(subscriptionId: String) async throws {
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)

        lock.lock()
        defer { lock.unlock() }

        guard var status = subscriptions[subscriptionId] else {
            throw PaymentProcessorError.subscriptionNotFound(subscriptionId)
        }
        status.cancelledAt = Date()
        subscriptions[subscriptionId] = status
    }

    func reactivateSubscription(subscriptionId: String) async throws -> ProcessorSubscriptionStatus {
        try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)

        lock.lock()
        defer { lock.unlock() }

        guard var status = subscriptions[subscriptionId] else {
            throw PaymentProcessorError.subscriptionNotFound(subscriptionId)
        }
        status.cancelledAt = nil
        subscriptions[subscriptionId] = status
        return status
    }
}