protocol MetaAdsServiceProtocol {
  func log(_ event: MetaAnalyticsEvent)
  func initialize()
}

// Production implementation
class MetaAdsService: MetaAdsServiceProtocol {
  func log(_ event: MetaAnalyticsEvent) {
    // Call real Meta SDK
  }

  func initialize() {
    // Initialize real Meta SDK
  }
}

// Mock for testing
class MockMetaAdsService: MetaAdsServiceProtocol {
  var loggedEvents: [MetaAnalyticsEvent] = []
  
  func log(_ event: MetaAnalyticsEvent) {
    loggedEvents.append(event) // Just collect events
  }

  func initialize() {
    // No-op for testing
  }
}

// Test example
@MainActor
class TestExample {
  // Add test logic here
}