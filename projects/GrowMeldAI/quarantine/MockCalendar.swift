import Foundation

/// Calendar that returns fixed "now" for deterministic testing
public struct MockCalendar: Calendar.ComponentsProvider {
    public let referenceDate: Date
    private let baseCalendar: Calendar
    
    public init(referenceDate: Date, baseCalendar: Calendar = .current) {
        self.referenceDate = referenceDate
        self.baseCalendar = baseCalendar
    }
    
    /// Helper: Create mock calendar for a specific date
    static func fixed(year: Int, month: Int, day: Int) -> Calendar {
        var calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        components.minute = 0
        
        // Note: In real code, you'd inject the current date into FreemiumService
        // This is a simplified version for demonstration
        return calendar
    }
    
    /// Helper: Create date at specific time
    static func date(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }
}