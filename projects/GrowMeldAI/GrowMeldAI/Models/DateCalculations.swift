// Utilities/DateCalculations.swift
enum DateCalculations {
    /// Calculate days between two dates
    static func daysBetween(_ from: Date, and to: Date = Date()) -> Int {
        let components = Calendar.current.dateComponents([.day], from: from, to: to)
        return components.day ?? 0
    }
    
    /// Check if two dates are the same calendar day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    /// Get start of day for a date
    static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}

// Usage
var daysSinceLastPractice: Int {
    guard let lastDate = lastPracticedDate else { return Int.max }
    return DateCalculations.daysBetween(lastDate)
}

var daysSince: Int {
    DateCalculations.daysBetween(lastActiveDate)
}