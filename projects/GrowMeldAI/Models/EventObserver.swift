import Foundation

struct QueuedEvent {
    let event: AppEvent
    let timestamp: Date
}

protocol AppEvent {}

protocol EventObserver: AnyObject {
    func handle(_ event: AppEvent) async
}

actor EventBus {
    private var observers: [String: [EventObserver]] = [:]
    private var eventQueue: [QueuedEvent] = []
    private var isOnline: Bool = true

    func subscribe(_ observer: EventObserver, to eventTypes: [String]) async {
        for eventType in eventTypes {
            if observers[eventType] == nil {
                observers[eventType] = []
            }
            observers[eventType]?.append(observer)
        }
    }

    func post(_ event: AppEvent) async {
        let eventType = String(describing: type(of: event))

        if isOnline {
            if let eventObservers = observers[eventType] {
                for observer in eventObservers {
                    await observer.handle(event)
                }
            }
        } else {
            eventQueue.append(QueuedEvent(event: event, timestamp: Date()))
        }
    }

    func syncQueuedEvents() async {
        for queuedEvent in eventQueue {
            await post(queuedEvent.event)
        }
        eventQueue.removeAll()
    }

    func setOnline(_ online: Bool) {
        isOnline = online
    }
}