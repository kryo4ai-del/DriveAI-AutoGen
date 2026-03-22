import Foundation

@MainActor
final class AnalyticsService: Sendable {
    static let shared = AnalyticsService()
    
    enum Event {
        case exercisesLoaded(count: Int)
        case exerciseFiltered(category: String?)
        case exerciseSelected(id: String, name: String, category: String)
        case exerciseStarted(id: String, duration: Int)
        case error(message: String)
    }
    
    private init() {}
    
    func track(event: Event) {
        #if DEBUG
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("📊 [\(timestamp)] \(event)")
        #endif
        
        // TODO: Integrate with Firebase Analytics, Amplitude, or custom backend
        // Examples:
        // Analytics.logEvent("exercise_selected", parameters: [...])
        // Amplitude.instance().logEvent("exercise_selected", withEventProperties: [...])
    }
}