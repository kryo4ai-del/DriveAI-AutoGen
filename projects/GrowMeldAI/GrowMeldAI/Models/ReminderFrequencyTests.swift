import XCTest
@testable import DriveAI

final class ReminderFrequencyTests: XCTestCase {
    
    // MARK: - Display Names
    
    func testDisplayNames() {
        XCTAssertEqual(ReminderFrequency.daily.displayName, "Täglich")
        XCTAssertEqual(ReminderFrequency.weekdaysOnly.displayName, "Mo-Fr (Wochentage)")
    }
    
    // MARK: - Next Fire Date Calculation
    
    func testDailyNextFireDateTodayNotPassed() {
        let calendar = Calendar.current
        
        // Schedule for 9:00 AM
        let scheduledTime = DateComponents(hour: 9, minute: 0)
        
        // Reference: 8:00 AM today
        let referenceDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        
        let nextDate = ReminderFrequency.daily.nextFireDate(
            at: scheduledTime,
            after: referenceDate
        )!
        
        // Should be today at 9:00
        XCTAssertEqual(calendar.component(.hour, from: nextDate), 9)
        XCTAssertEqual(calendar.component(.minute, from: nextDate), 0)
        XCTAssertEqual(
            calendar.component(.day, from: nextDate),
            calendar.component(.day, from: referenceDate)
        )
    }
    
    func testDailyNextFireDateTodayAlreadyPassed() {
        let calendar = Calendar.current
        
        // Schedule for 9:00 AM
        let scheduledTime = DateComponents(hour: 9, minute: 0)
        
        // Reference: 10:00 AM today (scheduled time passed)
        let referenceDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        
        let nextDate = ReminderFrequency.daily.nextFireDate(
            at: scheduledTime,
            after: referenceDate
        )!
        
        // Should be tomorrow at 9:00
        XCTAssertEqual(calendar.component(.hour, from: nextDate), 9)
        XCTAssertEqual(calendar.component(.minute, from: nextDate), 0)
        
        let dayDiff = calendar.dateComponents([.day], from: referenceDate, to: nextDate).day
        XCTAssertEqual(dayDiff, 1)
    }
    
    func testWeekdaysSkipsWeekend() {
        let calendar = Calendar.current
        let scheduledTime = DateComponents(hour: 9, minute: 0)
        
        // Find a Saturday
        let today = Date()
        var testDate = today
        var dayOfWeek = calendar.component(.weekday, from: testDate)
        
        while dayOfWeek != 7 {  // 7 = Saturday
            testDate = calendar.date(byAdding: .day, value: 1, to: testDate)!
            dayOfWeek = calendar.component(.weekday, from: testDate)
        }
        
        let saturdayMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: testDate)!
        
        let nextDate = ReminderFrequency.weekdaysOnly.nextFireDate(
            at: scheduledTime,
            after: saturdayMorning
        )!
        
        // Should skip to Monday
        let nextDayOfWeek = calendar.component(.weekday, from: nextDate)
        XCTAssertNotEqual(nextDayOfWeek, 7)  // Not Saturday
        XCTAssertNotEqual(nextDayOfWeek, 1)  // Not Sunday
    }
    
    func testWeekdaysAllowsWeekday() {
        let calendar = Calendar.current
        let scheduledTime = DateComponents(hour: 9, minute: 0)
        
        // Find a Monday
        let today = Date()
        var testDate = today
        var dayOfWeek = calendar.component(.weekday, from: testDate)
        
        while dayOfWeek != 2 {  // 2 = Monday
            testDate = calendar.date(byAdding: .day, value: 1, to: testDate)!
            dayOfWeek = calendar.component(.weekday, from: testDate)
        }
        
        let mondayMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: testDate)!
        
        let nextDate = ReminderFrequency.weekdaysOnly.nextFireDate(
            at: scheduledTime,
            after: mondayMorning
        )!
        
        // Should be same day (Monday) at 9:00
        XCTAssertEqual(calendar.component(.hour, from: nextDate), 9)
        XCTAssertEqual(calendar.component(.day, from: nextDate), calendar.component(.day, from: testDate))
    }
    
    // MARK: - Edge Cases
    
    func testNextFireDateMidnight() {
        let scheduledTime = DateComponents(hour: 0, minute: 0)
        let nextDate = ReminderFrequency.daily.nextFireDate(at: scheduledTime)
        
        XCTAssertNotNil(nextDate)
        XCTAssertEqual(Calendar.current.component(.hour, from: nextDate!), 0)
        XCTAssertEqual(Calendar.current.component(.minute, from: nextDate!), 0)
    }
    
    func testNextFireDate2359() {
        let scheduledTime = DateComponents(hour: 23, minute: 59)
        let nextDate = ReminderFrequency.daily.nextFireDate(at: scheduledTime)
        
        XCTAssertNotNil(nextDate)
        XCTAssertEqual(Calendar.current.component(.hour, from: nextDate!), 23)
        XCTAssertEqual(Calendar.current.component(.minute, from: nextDate!), 59)
    }
}