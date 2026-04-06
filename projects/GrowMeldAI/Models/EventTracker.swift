// EventTracker properly awaits actor calls
@MainActor
class EventTracker: ObservableObject {
    nonisolated private let localQueue: LocalEventQueue
    
    nonisolated func log(_ event: TrackingEvent) {
        // Spawn background task (don't block MainActor)
        Task {
            try? await localQueue.enqueue(event)
        }
    }
}

// OR: Return a Result to caller
func log(_ event: TrackingEvent) async -> Result<Void, Error> {
    await localQueue.enqueue(event)
}