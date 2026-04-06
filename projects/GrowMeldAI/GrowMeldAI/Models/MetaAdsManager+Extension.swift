extension MetaAdsManager {
  func logWithFallback(_ event: MetaAnalyticsEvent) {
    do {
      try logEvent(event)
    } catch {
      logger.error("Meta event logging failed: \(error)")
      // App continues working; ads just silent-fail
      // User experience unaffected
    }
  }
}