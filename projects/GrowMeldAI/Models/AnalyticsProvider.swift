protocol AnalyticsProvider {
    func logEvent(_ name: String, parameters: [String: Any]?) throws
}

extension SubscriptionViewModel {
    private func safeLogAnalyticsEvent(_ name: String, parameters: [String: Any]?) {
        do {
            try analyticsProvider.logEvent(name, parameters: parameters)
        } catch {
            // Fail silently; don't let analytics errors crash user flow
            debugPrint("Analytics error: \(error)")
        }
    }
}

// Usage:
safeLogAnalyticsEvent("purchase_failed", parameters: [
    "code": error.diagnosticCode,
    "retry_count": intent.retryCount
])