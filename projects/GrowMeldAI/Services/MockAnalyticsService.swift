#if DEBUG
// Use Xcode's Console logging with accessibility in mind
os_log("🧪 Mock Analytics: %@", log: OSLog.default, type: .debug, "\(event)")

// Or add to a debug view accessible via VoiceOver
@MainActor
class MockAnalyticsService: AnalyticsService {
    @Published private(set) var lastLoggedEventDescription = ""
    
    func logEvent(_ event: AnalyticsEvent) async {
        loggedEvents.append(event)
        
        #if DEBUG
        lastLoggedEventDescription = "Analytics: \(event.localizedDescription)"
        print("📊 \(lastLoggedEventDescription)")
        #endif
    }
}