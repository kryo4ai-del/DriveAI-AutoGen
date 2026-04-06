// Mock Firebase (stub analytics calls)
class MockFirebaseAnalyticsService: FirebaseAnalyticsService {
    var loggedEvents: [AnalyticsEvent] = []
    override func logConfidentAnswer(...) {
        loggedEvents.append(event)
    }
}

// Real UserDefaults in tests (isolated per test)
// Real AnalyticsEventQueue (test persistence directly)