import Foundation

/// UserDefaults-backed persistence for daily reminders.
/// Thread-safe via @MainActor. Protocol-based for future Core Data migration.
@MainActor
final class RemindersDataService: RemindersDataServiceType {
    private let defaults: UserDefaults
    private static let storageKey = "driveai.reminders.v1"
    private static let migrationFlagKey = "driveai.reminders.migrated_v1"
    
    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }
    
    // MARK: - CRUD Operations
    
    func fetchAll() async throws -> [DailyReminder] {
        guard let data = defaults.data(forKey: Self.storageKey) else {
            return []
        }
        
        do {
            let reminders = try JSONDecoder().decode([DailyReminder].self, from: data)
            return reminders.sorted { $0.scheduledTime < $1.scheduledTime }
        } catch {
            throw RemindersError.storageFailure("Decode failed: \(error.localizedDescription)")
        }
    }
    
    func save(_ reminder: DailyReminder) async throws {
        do {
            var reminders = try await fetchAll()
            
            // Update or insert (upsert)
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                reminders[index] = reminder
            } else {
                reminders.append(reminder)
            }
            
            let encoded = try JSONEncoder().encode(reminders)
            defaults.set(encoded, forKey: Self.storageKey)
        } catch let error as RemindersError {
            throw error
        } catch {
            throw RemindersError.storageFailure("Save failed: \(error.localizedDescription)")
        }
    }
    
    func delete(id: UUID) async throws {
        do {
            var reminders = try await fetchAll()
            reminders.removeAll { $0.id == id }
            let encoded = try JSONEncoder().encode(reminders)
            defaults.set(encoded, forKey: Self.storageKey)
        } catch let error as RemindersError {
            throw error
        } catch {
            throw RemindersError.storageFailure("Delete failed: \(error.localizedDescription)")
        }
    }
    
    func deleteAll() async throws {
        defaults.removeObject(forKey: Self.storageKey)
    }
    
    // MARK: - Migration (Future-Proofing)
    
    /// Perform one-time data migration if needed (e.g., v0 → v1 schema).
    nonisolated func performMigrationIfNeeded() {
        let hasMigrated = UserDefaults.standard.bool(forKey: Self.migrationFlagKey)
        guard !hasMigrated else { return }
        
        // Example: if v0 data exists at old key, migrate to v1
        if let oldData = UserDefaults.standard.data(forKey: "driveai.reminders.old") {
            UserDefaults.standard.set(oldData, forKey: Self.storageKey)
            UserDefaults.standard.removeObject(forKey: "driveai.reminders.old")
        }
        
        UserDefaults.standard.set(true, forKey: Self.migrationFlagKey)
    }
}