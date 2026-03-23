import Foundation

protocol StudyStreakServiceProtocol {
    /// Returns all stored streak records, sorted ascending by date.
    func fetchAllRecords() -> [StreakRecord]

    /// Saves a new study session record.
    func saveRecord(_ record: StreakRecord)

    /// Removes all stored records (useful for testing / reset).
    func clearAllRecords()

    /// Returns the record for today, if one exists.
    func fetchTodayRecord() -> StreakRecord?

    /// Calculates the current consecutive-day streak ending today (or yesterday).
    func calculateCurrentStreak() -> Int

    /// Returns records for the last `days` calendar days (oldest first).
    func fetchRecords(forLastDays days: Int) -> [StreakRecord]
}