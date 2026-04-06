// Create: /Services/Analytics/OfflineAnalyticsQueue.swift

class OfflineAnalyticsQueue {
    private let db: LocalDataService
    private let maxQueueSize = 1000 // Prevent unbounded growth
    
    func enqueueEvent(_ event: AnalyticsEvent) {
        // Validate before queueing
        guard !event.containsPII() else {
            print("⚠️ Skipping event: contains PII")
            return
        }
        
        // Store with unique ID to detect duplicates
        let eventWithID = event.withUniqueID(UUID())
        db.insert("analytics_queue", [
            "id": eventWithID.id,
            "event_json": encryptJSON(eventWithID),
            "timestamp": Date(),
            "retry_count": 0
        ])
        
        // Prune if exceeding max size (FIFO)
        if db.count("analytics_queue") > maxQueueSize {
            db.deleteOldest("analytics_queue", count: 100)
        }
    }
    
    func flushQueuedEvents() async throws {
        let events = db.select("analytics_queue", limit: 100)
        for batch in events.chunked(into: 10) {
            do {
                try await submitToMeta(batch)
                db.delete("analytics_queue", where: "id IN (\(batch.map { $0.id }))")
            } catch {
                // Exponential backoff: retry_count++
                db.update("analytics_queue", 
                    where: "id IN (...)", 
                    set: ["retry_count = retry_count + 1"])
            }
        }
    }
}

// Privacy verification:
// [ ] Queued events are encrypted at rest (SQLcipher)
// [ ] No PII validation before queueing
// [ ] Automatic purge after 30 days if network never returns