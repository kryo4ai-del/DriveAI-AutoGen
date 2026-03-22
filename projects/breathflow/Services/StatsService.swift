// Services/StatsService.swift
import Foundation
import Observation

@Observable
@MainActor
final class StatsService: Sendable {
    static let shared = StatsService()
    
    /// All saved breathing sessions.
    private(set) var allSessions: [SessionRecord] = []
    
    private let sessionsKey = "breathing_sessions"
    private let backupPrefix = "breathing_sessions_backup"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        loadAllSessions()
    }
    
    // MARK: - Persistence (C1 Fix: State Coherency)
    
    /// Saves a new session and immediately updates in-memory state.
    /// - Parameter record: The session record to save
    /// - Returns: True if save succeeded, false otherwise
    func saveSession(_ record: SessionRecord) -> Bool {
        do {
            var current = allSessions
            current.append(record)
            let data = try encoder.encode(current)
            UserDefaults.standard.set(data, forKey: sessionsKey)
            
            // ✓ Immediately sync in-memory state (fixes H1)
            allSessions = current
            return true
        } catch {
            print("❌ Failed to save session: \(error)")
            return false
        }
    }
    
    /// Loads all sessions from UserDefaults with error recovery.
    /// - Note: Corrupted data is backed up automatically
    func loadAllSessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
            allSessions = []
            return
        }
        
        do {
            allSessions = try decoder.decode([SessionRecord].self, from: data)
        } catch {
            print("❌ CRITICAL: Failed to decode sessions: \(error)")
            logCorruptedDataBackup(data)
            allSessions = []
        }
    }
    
    /// Deletes a session by ID.
    /// - Parameter id: The session ID to delete
    /// - Returns: True if deletion succeeded, false otherwise
    func deleteSession(_ id: UUID) -> Bool {
        guard let index = allSessions.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        allSessions.remove(at: index)
        
        do {
            let data = try encoder.encode(allSessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
            return true
        } catch {
            print("❌ Failed to delete session: \(error)")
            return false
        }
    }
    
    // MARK: - Aggregations (H2 Fix: Timezone-Aware Weekly Calculation)
    
    /// Calculates total minutes for sessions in the last 7 calendar days.
    /// - Note: Uses local calendar to handle timezone boundaries correctly
    func weeklyMinutes() -> Int {
        sessionsThisWeek().reduce(0) { $0 + $1.durationMinutes }
    }
    
    /// Returns all sessions from the last 7 calendar days.
    /// - Note: Timezone-aware to prevent edge-case bugs at date boundaries
    func sessionsThisWeek() -> [SessionRecord] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let today = calendar.startOfDay(for: Date())
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return []
        }
        
        return allSessions.filter { session in
            let sessionDay = calendar.startOfDay(for: session.date)
            return sessionDay >= sevenDaysAgo && sessionDay <= today
        }
    }
    
    /// Calculates total minutes across all sessions.
    func totalMinutes() -> Int {
        allSessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    /// Counts sessions for a specific technique.
    func sessionCount(for technique: BreathingTechnique) -> Int {
        allSessions.filter { $0.techniqueEnum == technique }.count
    }
    
    /// Returns the most recently completed session.
    func latestSession() -> SessionRecord? {
        allSessions.max(by: { $0.date < $1.date })
    }
    
    // MARK: - Private Helpers (M1 Fix: Error Recovery)
    
    /// Backs up corrupted data for debugging.
    private func logCorruptedDataBackup(_ data: Data) {
        let timestamp = Date().timeIntervalSince1970
        let backupKey = "\(backupPrefix)_\(Int(timestamp))"
        UserDefaults.standard.set(data, forKey: backupKey)
        print("📦 Corrupted data backed up to: \(backupKey)")
    }
}