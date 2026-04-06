// Add to NotificationViewModel:
enum NotificationAnalyticsEvent {
    case consentShown
    case consentGranted
    case consentDenied
    case consentSkipped
}

func trackEvent(_ event: NotificationAnalyticsEvent) {
    // Post to analytics service (Mixpanel, Firebase, etc.)
    NotificationCenter.default.post(name: NSNotification.Name("Analytics.Event"), object: event)
}