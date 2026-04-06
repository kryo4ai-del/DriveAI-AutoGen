// Refactor MemoryEventLog
@MainActor
class MemoryEventLog {
    private let storage: LocalStorageProvider
    @Published private(set) var recentEvents: [MemoryEvent] = []
    
    init(storage: LocalStorageProvider) {
        self.storage = storage
        Task { await loadRecent() }
    }
    
    func log(_ event: MemoryEvent) async throws {
        // Append locally first
        await MainActor.run {
            self.recentEvents.append(event)
        }
        // Persist async
        var events = (try? await storage.read(
            key: "memory_events",
            type: [MemoryEvent].self
        )) ?? []
        events.append(event)
        try await storage.write(key: "memory_events", value: events)
    }
    
    private func loadRecent() async {
        do {
            let events = try await storage.read(
                key: "memory_events",
                type: [MemoryEvent].self
            )
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            await MainActor.run {
                self.recentEvents = events.filter { $0.timestamp >= cutoff }
            }
        } catch {
            print("Error loading events:", error)
        }
    }
    
    func getStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        for event in recentEvents.sorted(by: { $0.timestamp > $1.timestamp }) {
            if calendar.isDate(checkDate, inSameDayAs: event.timestamp) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            }
        }
        return streak
    }
}