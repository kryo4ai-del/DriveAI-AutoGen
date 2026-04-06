// ❌ CURRENT
struct ShareAnalyticsEvent {
    let shareMethod: String  // "twitter", "whatsapp", "mail" — typos silently fail
}

// Called as:
analyticsService.track(event: ShareAnalyticsEvent(shareMethod: "twiter"))  // Typo!