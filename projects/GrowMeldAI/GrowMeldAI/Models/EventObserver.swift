// Services/EventBus/EventBus.swift

actor EventBus {
    private var observers: [String: [EventObserver]] = [:]
    private var eventQueue: [QueuedEvent] = []
    private var isOnline: Bool = true
    
    // Register observer (e.g., AnalyticsService, FeatureFlagService)
    func subscribe(_ observer: EventObserver, to eventTypes: [String]) async {
        for eventType in eventTypes {
            if observers[eventType] == nil {
                observers[eventType] = []
            }
            observers[eventType]?.append(observer)
        }
    }
    
    // Fire event (from ViewModel)
    func post(_ event: AppEvent) async {
        let eventType = String(describing: type(of: event))
        
        if isOnline {
            // Dispatch immediately to all observers
            if let eventObservers = observers[eventType] {
                for observer in eventObservers {
                    await observer.handle(event)
                }
            }
        } else {
            // Queue event for later (offline-first)
            eventQueue.append(QueuedEvent(event: event, timestamp: Date()))
        }
    }
    
    // Sync queued events when network available
    func syncQueuedEvents() async {
        for queuedEvent in eventQueue {
            await post(queuedEvent.event) // Retry dispatch
        }
        eventQueue.removeAll()
    }
}

protocol EventObserver: AnyObject {
    func handle(_ event: AppEvent) async
}