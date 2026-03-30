// AnalyticsEvents.swift
// DAI-Core Standard Analytics Events
//
// Enum of all standard events every DAI-Core iOS app should track.
// All event names are prefixed with `dai_` automatically.

import Foundation

/// Standard analytics events for DAI-Core iOS apps.
/// Use with `AnalyticsManager.shared.log(_:)`.
enum DAIAnalyticsEvent {

    // MARK: - Session Events

    /// App opened / foregrounded.
    case appOpen
    /// App sent to background.
    case appBackground

    // MARK: - Onboarding Funnel

    /// User started the onboarding flow.
    case onboardingStart
    /// User completed a specific onboarding step.
    case onboardingStep(step: Int, name: String)
    /// User completed the full onboarding.
    case onboardingComplete
    /// User skipped onboarding.
    case onboardingSkip

    // MARK: - Feature Usage

    /// User actively used a feature.
    case featureUsed(name: String)
    /// User discovered / saw a feature for the first time.
    case featureDiscovered(name: String)

    // MARK: - Engagement

    /// Active session duration heartbeat.
    case sessionActive(durationSeconds: Int)
    /// User viewed a piece of content.
    case contentViewed(contentId: String, contentType: String)

    // MARK: - Monetization

    /// User initiated a purchase flow.
    case purchaseStart(productId: String)
    /// Purchase completed successfully.
    case purchaseComplete(productId: String, value: Double, currency: String)
    /// User started a subscription.
    case subscriptionStart(planId: String)
    /// An ad was shown to the user.
    case adImpression(adType: String)

    // MARK: - Errors

    /// A non-fatal error occurred.
    case errorOccurred(domain: String, code: Int, description: String)

    // MARK: - Event Name

    /// Firebase event name, prefixed with `dai_`.
    var name: String {
        let prefix = "dai_"
        switch self {
        // Session
        case .appOpen:
            return "\(prefix)app_open"
        case .appBackground:
            return "\(prefix)app_background"

        // Onboarding
        case .onboardingStart:
            return "\(prefix)onboarding_start"
        case .onboardingStep:
            return "\(prefix)onboarding_step"
        case .onboardingComplete:
            return "\(prefix)onboarding_complete"
        case .onboardingSkip:
            return "\(prefix)onboarding_skip"

        // Feature Usage
        case .featureUsed:
            return "\(prefix)feature_used"
        case .featureDiscovered:
            return "\(prefix)feature_discovered"

        // Engagement
        case .sessionActive:
            return "\(prefix)session_active"
        case .contentViewed:
            return "\(prefix)content_viewed"

        // Monetization
        case .purchaseStart:
            return "\(prefix)purchase_start"
        case .purchaseComplete:
            return "\(prefix)purchase_complete"
        case .subscriptionStart:
            return "\(prefix)subscription_start"
        case .adImpression:
            return "\(prefix)ad_impression"

        // Errors
        case .errorOccurred:
            return "\(prefix)error_occurred"
        }
    }

    // MARK: - Event Parameters

    /// Event-specific parameters dictionary. Returns `nil` for events without parameters.
    var parameters: [String: Any]? {
        switch self {
        // Session — no extra params
        case .appOpen, .appBackground:
            return nil

        // Onboarding
        case .onboardingStart, .onboardingComplete, .onboardingSkip:
            return nil
        case .onboardingStep(let step, let name):
            return [
                "step": step,
                "step_name": name
            ]

        // Feature Usage
        case .featureUsed(let name):
            return ["feature_name": name]
        case .featureDiscovered(let name):
            return ["feature_name": name]

        // Engagement
        case .sessionActive(let durationSeconds):
            return ["duration_seconds": durationSeconds]
        case .contentViewed(let contentId, let contentType):
            return [
                "content_id": contentId,
                "content_type": contentType
            ]

        // Monetization
        case .purchaseStart(let productId):
            return ["product_id": productId]
        case .purchaseComplete(let productId, let value, let currency):
            return [
                "product_id": productId,
                "value": value,
                "currency": currency
            ]
        case .subscriptionStart(let planId):
            return ["plan_id": planId]
        case .adImpression(let adType):
            return ["ad_type": adType]

        // Errors
        case .errorOccurred(let domain, let code, let description):
            return [
                "error_domain": domain,
                "error_code": code,
                "error_description": description
            ]
        }
    }
}
