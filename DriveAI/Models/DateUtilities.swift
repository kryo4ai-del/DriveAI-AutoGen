// Services/DateUtilities.swift
import Foundation

/// Centralized date utilities for progress tracking.
/// Ensures consistent timezone handling across models.
struct DateUtilities {
    private static let progressCalendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC") ?? .current
        return cal
    }()
    
    /// Calendar day boundary (midnight UTC).
    static func startOfDay(_ date: Date) -> Date {
        progressCalendar.startOfDay(for: date)
    }
    
    /// Today's date at midnight.
    static var today: Date {
        startOfDay(.now)
    }
    
    /// Days between two calendar days (ignores time).
    static func daysDifference(from: Date, to: Date) -> Int {
        progressCalendar.dateComponents([.day], from: startOfDay(from), to: startOfDay(to)).day ?? 0
    }
    
    /// Check if date is today.
    static func isToday(_ date: Date) -> Bool {
        startOfDay(date) == today
    }
    
    /// Check if date is yesterday.
    static func isYesterday(_ date: Date) -> Bool {
        guard let yesterday = progressCalendar.date(byAdding: .day, value: -1, to: today) else {
            return false
        }
        return startOfDay(date) == yesterday
    }
    
    /// Next calendar day.
    static func nextDay(after date: Date) -> Date? {
        progressCalendar.date(byAdding: .day, value: 1, to: startOfDay(date))
    }
}