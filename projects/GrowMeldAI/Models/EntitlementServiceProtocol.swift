// EntitlementService.swift
import Foundation
import StoreKit

/// Service for managing user entitlements and premium feature access
protocol EntitlementServiceProtocol: AnyObject {
    /// Checks if user has access to premium features
    func hasPremiumAccess() async -> Bool

    /// Refreshes entitlements from App Store
    func refreshEntitlements() async throws

    /// Validates receipt with server-side validation
    func validateReceipt() async throws -> Bool

    /// Current entitlement status
    var currentEntitlement: EntitlementStatus { get }
}

enum EntitlementStatus {
    case loading
    case active
    case expired
    case notPurchased
}
