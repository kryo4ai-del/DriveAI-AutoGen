// IAPConfiguration.swift
import Foundation

/// Configuration for IAP products
struct IAPConfiguration {
    let productIdentifiers: Set<String>
    let premiumFeatures: Set<PremiumFeature>

    static let standard: IAPConfiguration = {
        let features: Set<PremiumFeature> = [
            .examSimulations,
            .advancedAnalytics,
            .detailedExplanations,
            .adFreeExperience
        ]

        return IAPConfiguration(
            productIdentifiers: Set([
                "com.driveai.premium.monthly",
                "com.driveai.premium.yearly",
                "com.driveai.premium.lifetime"
            ]),
            premiumFeatures: features
        )
    }()
}