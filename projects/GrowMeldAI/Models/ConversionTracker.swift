import Foundation

struct TrackingEvent {
    let name: String
    let parameters: [String: String]

    init(name: String, parameters: [String: String] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

class ConversionTracker {
    private let userDefaults = UserDefaults.standard
    private let queueKey = "com.growmeldai.conversiontracker.eventqueue"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {}

    func logEvent(_ event: TrackingEvent) {
        enqueueLocally(event)
    }

    private func enqueueLocally(_ event: TrackingEvent) {
        var queue = loadQueue()
        let entry = EventEntry(name: event.name, parameters: event.parameters, timestamp: Date())
        queue.append(entry)
        if let data = try? encoder.encode(queue) {
            userDefaults.set(data, forKey: queueKey)
        }
    }

    func flushQueue() -> [TrackingEvent] {
        let queue = loadQueue()
        userDefaults.removeObject(forKey: queueKey)
        return queue.map { TrackingEvent(name: $0.name, parameters: $0.parameters) }
    }

    private func loadQueue() -> [EventEntry] {
        guard let data = userDefaults.data(forKey: queueKey),
              let entries = try? decoder.decode([EventEntry].self, from: data) else {
            return []
        }
        return entries
    }
}

private struct EventEntry: Codable {
    let name: String
    let parameters: [String: String]
    let timestamp: Date
}