// AnalyticsManager.swift
// DAI-Core Firebase Analytics Manager
//
// Central analytics singleton for all DriveAI iOS apps.
// Generic template — no app-specific logic.

import Foundation
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

/// Central Analytics Manager for DAI-Core iOS apps.
/// Singleton pattern — all methods are fire-and-forget.
final class AnalyticsManager {

    // MARK: - Singleton

    static let shared = AnalyticsManager()

    /// Prefix for all custom DAI events.
    private let eventPrefix = "dai_"

    /// Whether `configure()` has been called.
    private(set) var isConfigured = false

    private init() {}

    // MARK: - Configuration

    /// Initialize Firebase. Call once in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
    /// or in your SwiftUI `App.init()`.
    func configure() {
        guard !isConfigured else { return }
        FirebaseApp.configure()
        isConfigured = true

        // Enable Crashlytics collection
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    }

    // MARK: - Event Logging

    /// Log a custom event with optional parameters.
    /// The event name is automatically prefixed with `dai_`.
    func logEvent(name: String, parameters: [String: Any]? = nil) {
        let prefixedName = eventPrefix + name
        Analytics.logEvent(prefixedName, parameters: parameters)
    }

    /// Log a screen view event.
    func logScreenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }

    /// Log feature usage (convenience wrapper around `logEvent`).
    func logFeatureUsed(featureName: String) {
        logEvent(name: "feature_used", parameters: [
            "feature_name": featureName
        ])
    }

    /// Log a funnel step for conversion tracking.
    func logFunnelStep(funnelName: String, step: Int, stepName: String) {
        logEvent(name: "funnel_step", parameters: [
            "funnel_name": funnelName,
            "step": step,
            "step_name": stepName
        ])
    }

    /// Log a conversion event with optional monetary value.
    func logConversion(type: String, value: Double? = nil, currency: String? = nil) {
        var params: [String: Any] = [
            "conversion_type": type
        ]
        if let value = value {
            params[AnalyticsParameterValue] = value
        }
        if let currency = currency {
            params[AnalyticsParameterCurrency] = currency
        }
        logEvent(name: "conversion", parameters: params)
    }

    // MARK: - User Properties

    /// Set a custom user property.
    func setUserProperty(name: String, value: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    /// Set the app profile category. Used to segment analytics by app type.
    /// Recommended values: `gaming`, `education`, `utility`, `content`, `subscription`.
    func setAppProfile(profile: String) {
        setUserProperty(name: "dai_app_profile", value: profile)
    }

    // MARK: - Structured Event Logging

    /// Log a `DAIAnalyticsEvent` directly.
    func log(_ event: DAIAnalyticsEvent) {
        let prefixedName = event.name  // already prefixed
        Analytics.logEvent(prefixedName, parameters: event.parameters)
    }
}
