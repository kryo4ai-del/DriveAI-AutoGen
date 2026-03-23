import Foundation

struct StreakRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let minutesStudied: Int

    init(id: UUID = UUID(), date: Date = Date(), minutesStudied: Int) {
        self.id = id
        self.date = date
        self.minutesStudied = minutesStudied
    }

    /// Returns true if this record's date falls on the same calendar day as `other`.
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(date, inSameDayAs: other)
    }
}