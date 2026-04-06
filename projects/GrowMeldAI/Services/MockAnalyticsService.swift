#if DEBUG
import os
import Foundation
import Combine

// Or add to a debug view accessible via VoiceOver
@MainActor
class MockAnalyticsService {
    @Published private(set) var lastLoggedEventDescription = ""
    var loggedEvents: [String] = []

    func logEvent(_ event: String) {
        loggedEvents.append(event)

        // Use Xcode's Console logging with accessibility in mind
        os_log("🧪 Mock Analytics: %@", log: OSLog.default, type: .debug, "\(event)")

        lastLoggedEventDescription = "Analytics: \(event)"
        print("📊 \(lastLoggedEventDescription)")
    }
}
#endif