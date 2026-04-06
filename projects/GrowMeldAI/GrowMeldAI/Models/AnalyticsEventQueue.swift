@MainActor
final class AnalyticsEventQueue {
    private var queue: [AnalyticsEvent] = []
    
    func enqueue(_ event: AnalyticsEvent) {
        queue.append(event)
        saveToDisk()  // Safe: guaranteed on main thread
    }
    
    private func saveToDisk() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let encodedData = try? encoder.encode(queue) else { return }
        UserDefaults.standard.set(encodedData, forKey: storageKey)
    }
}