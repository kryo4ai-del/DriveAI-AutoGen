import Foundation

/// Utility functions for safe date calculations.
/// Handles Calendar operations defensively to prevent silent failures.
enum DateHelpers {
    /// Calculates the number of days between two dates.
    /// Uses Calendar.current with proper nil handling.
    /// 
    /// - Parameters:
    ///   - from: Start date
    ///   - to: End date (defaults to current time)
    /// - Returns: Number of days; returns 0 if calculation fails
    static func daysBetween(_ from: Date, _ to: Date = .now) -> Int {
        let components = Calendar.current.dateComponents([.day], from: from, to: to)
        return components.day ?? 0
    }
    
    /// Returns the start of day (00:00:00) for a given date.
    /// Strips time components (hour, minute, second).
    /// 
    /// - Parameter date: Date to normalize (defaults to current time)
    /// - Returns: Date at start of day
    static func startOfDay(_ date: Date = .now) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    /// Calculates a date that is N days in the past.
    /// 
    /// - Parameter days: Number of days ago
    /// - Returns: Date N days ago (or current date if calculation fails)
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
    }
    
    /// Determines if today is a new study day relative to a given date.
    /// 
    /// - Parameter since: Last activity date
    /// - Returns: True if at least one day has passed since the date
    static func isNewDay(since: Date) -> Bool {
        daysBetween(since) > 0
    }
}