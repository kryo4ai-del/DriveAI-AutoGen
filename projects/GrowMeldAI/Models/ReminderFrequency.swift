import Foundation

enum ReminderFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekdaysOnly = "weekdays"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Täglich"
        case .weekdaysOnly:
            return "Mo-Fr (Wochentage)"
        }
    }
    
    /// Calculate next fire date respecting frequency rules
    /// - Parameter scheduledTime: Hour and minute components
    /// - Parameter after: Reference date (default: now)
    /// - Returns: Next valid fire date or nil if invalid
    func nextFireDate(
        at scheduledTime: DateComponents,
        after referenceDate: Date = Date()
    ) -> Date? {
        var calendar = Calendar.current
        
        // Build target time for today
        var targetDate = calendar.date(
            bySettingHour: scheduledTime.hour ?? 9,
            minute: scheduledTime.minute ?? 0,
            second: 0,
            of: referenceDate
        ) ?? referenceDate
        
        // If time already passed, move to next day
        if targetDate <= referenceDate {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
        }
        
        // Apply frequency constraints
        switch self {
        case .daily:
            return targetDate
            
        case .weekdaysOnly:
            // Skip weekends (Sunday=1, Saturday=7)
            while calendar.component(.weekday, from: targetDate) > 6 {
                targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
            }
            return targetDate
        }
    }
}