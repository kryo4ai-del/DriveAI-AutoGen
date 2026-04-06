// Services/SubscriptionService.swift
import Foundation
import StoreKit

/// Service for managing subscription state and StoreKit interactions
final class SubscriptionService {
    private let userDefaults = UserDefaults.standard
    private let featureGateService = FeatureGateService.shared

    @MainActor
    func refreshSubscriptionStatus() async throws -> SubscriptionState {
        // Try to load from cache first
        if let cached = CachedEntitlement.loadFromCache(), !cached.isStale {
            return mapCachedEntitlementToState(cached)
        }

        // Fetch from StoreKit
        do {
            let state = try await fetchFromStoreKit()
            saveEntitlementToCache(state)
            return state
        } catch {
            // Fallback to cached state if available
            if let cached = CachedEntitlement.loadFromCache() {
                return mapCachedEntitlementToState(cached)
            }
            throw SubscriptionError.networkFailure
        }
    }

    @MainActor
    private func fetchFromStoreKit() async throws -> SubscriptionState {
        // In a real app, this would use StoreKit 2 APIs to fetch subscription status
        // For now, we simulate based on cached data or return a default state
        if let cached = CachedEntitlement.loadFromCache() {
            return mapCachedEntitlementToState(cached)
        }

        // Simulate loading state
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay

        // Simulate a free user
        return .free(expiryDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()))
    }

    private func saveEntitlementToCache(_ state: SubscriptionState) {
        switch state {
        case .free(let expiryDate):
            let entitlement = CachedEntitlement(
                tier: .free,
                expiryDate: expiryDate ?? Date(),
                cachedAt: Date()
            )
            entitlement.saveToCache()
        case .trial(let tier, let endDate):
            let entitlement = CachedEntitlement(
                tier: tier,
                expiryDate: endDate,
                cachedAt: Date()
            )
            entitlement.saveToCache()
        case .premium(let tier, let expiryDate, _):
            let entitlement = CachedEntitlement(
                tier: tier,
                expiryDate: expiryDate,
                cachedAt: Date()
            )
            entitlement.saveToCache()
        case .expired(let lastTier):
            let entitlement = CachedEntitlement(
                tier: lastTier,
                expiryDate: Date(),
                cachedAt: Date()
            )
            entitlement.saveToCache()
        case .loading, .error:
            break
        }
    }

    private func mapCachedEntitlementToState(_ entitlement: CachedEntitlement) -> SubscriptionState {
        if entitlement.expiryDate > Date() {
            return .premium(
                tier: entitlement.tier,
                expiryDate: entitlement.expiryDate,
                autoRenew: true
            )
        } else {
            return .expired(lastTier: entitlement.tier)
        }
    }

    func validateEntitlement(for featureID: String) async -> SubscriptionState {
        let state = try? await refreshSubscriptionStatus()
        guard let state = state else {
            return .error(.networkFailure)
        }

        guard let gate = FeatureGateService.shared.gates[featureID] else {
            return state
        }

        switch state {
        case .premium(let tier, _, _):
            if tier.rawValue >= gate.requiredTier.rawValue {
                return state
            } else {
                return .expired(lastTier: tier)
            }
        case .free, .trial, .expired, .loading, .error:
            return state
        }
    }
}