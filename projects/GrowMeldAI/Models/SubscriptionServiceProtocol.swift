// File: Sources/Services/SubscriptionService.swift
import Foundation
import StoreKit

/// Protocol for subscription service to enable mocking and testing
protocol SubscriptionServiceProtocol {
    func fetchAvailableProducts() async throws -> [SubscriptionPlan]
    func purchase(plan: SubscriptionPlan) async throws -> Bool
    func restorePurchases() async throws -> Bool
    func checkSubscriptionStatus() async -> Subscription?
    func validateReceipt() async throws -> Subscription?
}
