// DateUtilities.swift
import Foundation

final class DateUtilities {
    static let shared = DateUtilities()

    private init() {}

    func todayMidnightUTC() -> Date {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(
            from: calendar.dateComponents([.year, .month, .day], from: now)
        ) ?? now
    }

    func daysBetween(_ start: Date, and end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }

    func secondsUntilMidnight() -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        let midnight = calendar.date(
            from: calendar.dateComponents([.year, .month, .day], from: now)
        )?.addingTimeInterval(86400) ?? now

        return midnight.timeIntervalSince(now)
    }
}