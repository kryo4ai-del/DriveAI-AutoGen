// Integrates with LocalDataService for SQLite/JSON persistence
class ReminderRepository {
    func saveReminder(_ reminder: Reminder) async throws
    func deleteReminder(id: UUID) async throws
    func fetchReminders() async throws -> [Reminder]
    func fetchReminder(id: UUID) async throws -> Reminder?
    func updateLastTriggeredAt(id: UUID) async throws
}