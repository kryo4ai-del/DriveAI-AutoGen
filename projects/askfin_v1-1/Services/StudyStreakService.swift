import Foundation

final class StudyStreakService: StudyStreakServiceProtocol {

    // MARK: - Private constants

    private let recordsKey = "com.studystreak.records"
    private let calendar: Calendar
    private let userDefaults: UserDefaults

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.userDefaults = userDefaults
        self.calendar = calendar
    }

    // MARK: - StudyStreakServiceProtocol

    func fetchAllRecords() -> [StreakRecord] {
        guard let data = userDefaults.data(forKey: recordsKey) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let records = (try? decoder.decode([StreakRecord].self, from: data)) ?? []
        return records.sorted { $0.date < $1.date }
    }

    func saveRecord(_ record: StreakRecord) {
        var records = fetchAllRecords()

        // Replace existing record for the same day if present
        if let existingIndex = records.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: record.date) }) {
            let existing = records[existingIndex]
            let merged = StreakRecord(
                id: existing.id,
                date: existing.date,
                minutesStudied: existing.minutesStudied + record.minutesStudied
            )
            records[existingIndex] = merged
        } else {
            records.append(record)
        }

        persist(records)
    }

    func clearAllRecords() {
        userDefaults.removeObject(forKey: recordsKey)
    }

    func fetchTodayRecord() -> StreakRecord? {
        let today = Date()
        return fetchAllRecords().first { calendar.isDate($0.date, inSameDayAs: today) }
    }

    func calculateCurrentStreak() -> Int {
        let records = fetchAllRecords()
        guard !records.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())

        // Build a Set of day-start dates for O(1) lookup
        let studiedDays: Set<Date> = Set(records.map { calendar.startOfDay(for: $0.date) })

        // Determine the anchor: if user studied today start from today,
        // otherwise start from yesterday (streak may still be alive).
        let anchor: Date
        if studiedDays.contains(today) {
            anchor = today
        } else {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  studiedDays.contains(yesterday) else {
                return 0
            }
            anchor = yesterday
        }

        var streak = 0
        var current = anchor

        while studiedDays.contains(current) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = previous
        }

        return streak
    }

    func fetchRecords(forLastDays days: Int) -> [StreakRecord] {
        guard days > 0 else { return [] }
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else { return [] }

        return fetchAllRecords().filter { record in
            let recordDay = calendar.startOfDay(for: record.date)
            return recordDay >= startDate && recordDay <= today
        }
    }

    // MARK: - Private helpers

    private func persist(_ records: [StreakRecord]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(records) {
            userDefaults.set(data, forKey: recordsKey)
        }
    }
}