import Foundation

/// Local persistence for analytics events (JSON file-based)
class LocalEventStore {
    private let fileManager = FileManager.default
    private let eventsDirectory: URL
    private let eventsFile: URL
    
    init() {
        // Store in app's Documents directory
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        eventsDirectory = paths[0].appendingPathComponent("DriveAI_Analytics")
        eventsFile = eventsDirectory.appendingPathComponent("events.json")
        
        // Create directory if needed
        try? fileManager.createDirectory(at: eventsDirectory, 
                                        withIntermediateDirectories: true)
    }
    
    /// Save a single event to persistent storage
    func saveEvent(_ event: AnalyticsEvent) {
        var events = loadEvents()
        events.append(event)
        saveEvents(events)
    }
    
    /// Load all persisted events
    func loadEvents() -> [AnalyticsEvent] {
        guard fileManager.fileExists(atPath: eventsFile.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: eventsFile)
            let events = try JSONDecoder().decode([AnalyticsEvent].self, from: data)
            return events
        } catch {
            print("⚠️ Error loading events: \(error)")
            return []
        }
    }
    
    /// Delete all events
    func deleteAllEvents() {
        try? fileManager.removeItem(at: eventsFile)
    }
    
    /// Export events as JSON string
    func exportAsJSON() -> String? {
        let events = loadEvents()
        do {
            let data = try JSONEncoder().encode(events)
            return String(data: data, encoding: .utf8)
        } catch {
            print("⚠️ Error encoding events: \(error)")
            return nil
        }
    }
    
    // MARK: - Private
    
    private func saveEvents(_ events: [AnalyticsEvent]) {
        do {
            let data = try JSONEncoder().encode(events)
            try data.write(to: eventsFile)
        } catch {
            print("⚠️ Error saving events: \(error)")
        }
    }
}