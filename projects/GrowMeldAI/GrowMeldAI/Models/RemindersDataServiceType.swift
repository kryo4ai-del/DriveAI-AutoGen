import Foundation

/// Protocol for data persistence (supports future Core Data migration).
/// All operations are async-throws for future cloud sync compatibility.
@MainActor
protocol RemindersDataServiceType: AnyObject {
    func fetchAll() async throws -> [DailyReminder]
    func save(_ reminder: DailyReminder) async throws
    func delete(id: UUID) async throws
    func deleteAll() async throws
}