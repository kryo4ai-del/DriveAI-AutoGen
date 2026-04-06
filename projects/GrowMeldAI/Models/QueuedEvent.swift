// Services/EventBus/EventBus.swift

import Foundation

actor EventBus: Sendable {
    typealias EventHandler = (AppEvent) async -> Void
    
    private var handlers: [ObjectIdentifier: EventHandler] = [:]
    private var offlineQueue: [QueuedEvent] = []
    private var isOnline = true
    private let lock = NSLock()
    
    private struct QueuedEvent: Codable {
        let event: String // serialized event
        let timestamp: Date
        let retryCount: Int
    }
    
    static let shared = EventBus()
    
    // Register event handler
    func subscribe<O: AnyObject>(
        _ observer: O,
        handler: @escaping (AppEvent) async -> Void
    ) {
        let id = ObjectIdentifier(observer)
        handlers[id] = handler
    }
    
    // Unsubscribe
    func unsubscribe<O: AnyObject>(_ observer: O) {
        let id = ObjectIdentifier(observer)
        handlers.removeValue(forKey: id)
    }
    
    // Post event (main dispatch)
    func post(_ event: AppEvent) async {
        if isOnline {
            await dispatchEvent(event)
        } else {
            await queueEvent(event)
        }
    }
    
    // Set network status
    func setOnlineStatus(_ online: Bool) async {
        isOnline = online
        if online {
            await syncQueuedEvents()
        }
    }
    
    // Private: dispatch to all handlers
    private func dispatchEvent(_ event: AppEvent) async {
        let dispatchHandlers = handlers.values.map { $0 }
        for handler in dispatchHandlers {
            await handler(event)
        }
    }
    
    // Private: queue event for later
    private func queueEvent(_ event: AppEvent) async {
        let encoded = try? JSONEncoder().encode(event as? Encodable)
        let eventString = String(data: encoded ?? Data(), encoding: .utf8) ?? ""
        
        let queued = QueuedEvent(
            event: eventString,
            timestamp: Date(),
            retryCount: 0
        )
        offlineQueue.append(queued)
    }
    
    // Private: retry queued events
    private func syncQueuedEvents() async {
        var processed: [Int] = []
        
        for (index, queued) in offlineQueue.enumerated() {
            // Attempt to decode and dispatch
            if let eventData = queued.event.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(AppEvent.self, from: eventData) {
                await dispatchEvent(decoded)
                processed.append(index)
            } else if queued.retryCount < 3 {
                // Retry up to 3 times
                offlineQueue[index].retryCount += 1
            }
        }
        
        // Remove successfully processed events
        offlineQueue.removeAll { queued in
            processed.contains { offlineQueue[$0] === queued }
        }
    }
}