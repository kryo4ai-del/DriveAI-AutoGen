// PremiumFeatureGating.swift
import Foundation

/// Protocol for feature gating based on premium status
protocol PremiumFeatureGating {
    var entitlementService: EntitlementServiceProtocol { get }
    func isFeatureAvailable(_ feature: PremiumFeature) async -> Bool
}

final class DriveAIPremiumGating: PremiumFeatureGating {
    let entitlementService: EntitlementServiceProtocol

    init(entitlementService: EntitlementServiceProtocol) {
        self.entitlementService = entitlementService
    }

    func isFeatureAvailable(_ feature: PremiumFeature) async -> Bool {
        let hasAccess = await entitlementService.hasPremiumAccess()

        switch feature {
        case .examSimulations, .advancedAnalytics, .detailedExplanations:
            return hasAccess
        case .adFreeExperience:
            // Ad-free is always available in premium
            return hasAccess
        }
    }
}