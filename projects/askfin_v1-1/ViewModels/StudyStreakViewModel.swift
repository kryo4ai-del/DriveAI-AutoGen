import Foundation
import Combine

final class StudyStreakViewModel: ObservableObject {

    // MARK: - Published properties

    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var hasStudiedToday: Bool = false
    @Published private(set) var last7DayStatuses: [DayStatus] = []
    @Published private(set) var todayMinutes: Int = 0

    // MARK: - Nested types

    struct DayStatus: Identifiable {
        let id: UUID = UUID()
        let date: Date
        let didStudy: Bool
        let minutesStudied: Int

        var shortLabel: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return String(formatter.string(from: date).prefix(1))
        }
    }

    // MARK: - Private

    private let service: StudyStreakServiceProtocol
    private let calendar: Calendar

    // MARK: - Init

    init(service: StudyStreakServiceProtocol = StudyStreakService(), calendar: Calendar = .current) {
        self.service = service
        self.calendar = calendar
        refresh()
    }

    // MARK: - Public API

    /// Call this when the user logs a study session.
    func logStudySession(minutes: Int) {
        guard minutes > 0 else { return }
        let record = StreakRecord(minutesStudied: minutes)
        service.saveRecord(record)
        refresh()
    }

    /// Refreshes all published state from the service.
    func refresh() {
        currentStreak = service.calculateCurrentStreak()
        hasStudiedToday = service.fetchTodayRecord() != nil
        todayMinutes = service.fetchTodayRecord()?.minutesStudied ?? 0
        last7DayStatuses = buildLast7DayStatuses()
    }

    /// Resets all data (e.g. for testing or user-initiated reset).
    func resetAllData() {
        service.clearAllRecords()
        refresh()
    }

    // MARK: - Private helpers

    private func buildLast7DayStatuses() -> [DayStatus] {
        let records = service.fetchRecords(forLastDays: 7)
        let today = calendar.startOfDay(for: Date())

        // Map date -> minutes for quick lookup
        var minutesByDay: [Date: Int] = [:]
        for record in records {
            let day = calendar.startOfDay(for: record.date)
            minutesByDay[day, default: 0] += record.minutesStudied
        }

        var statuses: [DayStatus] = []
        for offset in (0..<7).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let minutes = minutesByDay[day] ?? 0
            statuses.append(DayStatus(date: day, didStudy: minutes > 0, minutesStudied: minutes))
        }
        return statuses
    }
}