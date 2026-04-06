import Foundation

/// Pure utility for calculating reminder trigger times and recurrence logic.
/// Thread-safe (stateless). Handles DST transitions gracefully.
struct ReminderScheduler {
    
    /// Calculate the next trigger date for a daily reminder.
    /// Uses Calendar.nextDate() to handle DST transitions safely.
    /// Returns DateComponents ready for UNCalendarNotificationTrigger.
    static func nextTriggerDate(
        for reminder: DailyReminder,
        after: Date = .now
    ) -> DateComponents {
        let calendar = Calendar.current
        
        // Extract HH:MM from reminder's scheduled time
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: reminder.scheduledTime
        )
        
        guard let hour = components.hour, let minute = components.minute else {
            // Fallback: schedule for tomorrow at midnight
            return safeFallbackDate(after: after, calendar: calendar)
        }
        
        // ✅ FIX: Use nextDate() which handles DST correctly
        var matchingComponents = DateComponents()
        matchingComponents.hour = hour
        matchingComponents.minute = minute
        matchingComponents.second = 0
        matchingComponents.timeZone = TimeZone.current
        
        guard let nextDate = calendar.nextDate(
            after: after,
            matching: matchingComponents,
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) else {
            return safeFallbackDate(after: after, calendar: calendar)
        }
        
        return calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .timeZone],
            from: nextDate
        )
    }
    
    /// Determine if a reminder should fire today (respecting streak threshold).
    static func shouldFireToday(
        reminder: DailyReminder,
        questionsAnsweredToday: Int = 0
    ) -> Bool {
        guard reminder.isEnabled else { return false }
        
        if let threshold = reminder.streakThreshold {
            return questionsAnsweredToday < threshold
        }
        
        return true
    }
    
    // MARK: - Helper
    
    /// Safe fallback: schedule for tomorrow at same time.
    /// Used when Calendar.nextDate() fails (should be rare).
    private static func safeFallbackDate(
        after: Date,
        calendar: Calendar
    ) -> DateComponents {
        let tomorrow = after.addingTimeInterval(24 * 3600)
        return calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: tomorrow
        )
    }
}