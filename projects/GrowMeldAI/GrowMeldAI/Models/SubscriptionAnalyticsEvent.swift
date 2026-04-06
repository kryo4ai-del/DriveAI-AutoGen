// MARK: - SubscriptionAnalytics.swift
import Foundation

enum SubscriptionAnalyticsEvent: String {
    case premiumProductsRequested
    case premiumProductsFailed
    case premiumCtaTapped
    case premiumPurchaseFailed
    case premiumPurchaseSuccess
    case premiumRestoreRequested
    case premiumRestoreSuccess
    case premiumRestoreFailed
    case trialExpiringSoon
}

final class FirebaseAnalyticsProvider: AnalyticsProvider {
    func logEvent(_ event: SubscriptionAnalyticsEvent, parameters: [String: Any]?) {
        logEvent(event.rawValue, parameters: parameters)
    }

    func logEvent(_ name: String, parameters: [String: Any]?) {
        // Firebase implementation
        Analytics.logEvent(name, parameters: parameters)
    }
}

final class MockAnalyticsProvider: AnalyticsProvider {
    private(set) var loggedEvents: [(name: String, parameters: [String: Any]?)] = []

    func logEvent(_ event: SubscriptionAnalyticsEvent, parameters: [String: Any]?) {
        logEvent(event.rawValue, parameters: parameters)
    }

    func logEvent(_ name: String, parameters: [String: Any]?) {
        loggedEvents.append((name: name, parameters: parameters))
    }
}