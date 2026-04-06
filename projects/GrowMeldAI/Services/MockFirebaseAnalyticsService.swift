import Foundation

struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]

    init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

class FirebaseAnalyticsService {
    func logConfidentAnswer(event: AnalyticsEvent) {}
}

class MockFirebaseAnalyticsService: FirebaseAnalyticsService {
    var loggedEvents: [AnalyticsEvent] = []

    override func logConfidentAnswer(event: AnalyticsEvent) {
        loggedEvents.append(event)
    }
}