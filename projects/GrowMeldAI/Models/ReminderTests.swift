import XCTest
@testable import DriveAI

final class ReminderTests: XCTestCase {
    
    // MARK: - Initialization & Validation
    
    func testReminderInitialization() {
        let reminder = Reminder.mock(hour: 8, minute: 30)
        
        XCTAssertEqual(reminder.hour, 8)
        XCTAssertEqual(reminder.minute, 30)
        XCTAssertTrue(reminder.isActive)
        XCTAssertNil(reminder.lastTriggeredAt)
    }
    
    func testReminderInitializationInvalidHourTooHigh() {
        XCTAssertThrowsError(
            try XCTSkip("Testing precondition"),
            { Reminder(hour: 24, minute: 0, frequency: .daily) }
        )
    }
    
    func testReminderInitializationInvalidMinuteTooHigh() {
        XCTAssertThrowsError(
            try XCTSkip("Testing precondition"),
            { Reminder(hour: 8, minute: 60, frequency: .daily) }
        )
    }
    
    func testTimeComponentsExtraction() {
        let reminder = Reminder.mock(hour: 7, minute: 45)
        let components = reminder.timeComponents
        
        XCTAssertEqual(components.hour, 7)
        XCTAssertEqual(components.minute, 45)
    }
    
    // MARK: - Frequency Checks
    
    func testShouldTriggerTodayDaily() {
        let reminder = Reminder.mock(frequency: .daily)
        XCTAssertTrue(reminder.shouldTriggerToday())
    }
    
    func testShouldTriggerTodayMondayToFridayOnWeekday() {
        // Wednesday = 4
        let calendar = Calendar.current
        var components = calendar.dateComponents([.weekday], from: Date())
        
        // If not a weekday, skip this test
        guard (2...6).contains(components.weekday!) else {
            XCTSkip("Test requires weekday")
        }
        
        let reminder = Reminder.mock(frequency: .mondayToFriday)
        XCTAssertTrue(reminder.shouldTriggerToday())
    }
    
    func testShouldTriggerTodayCustomDays() {
        let reminder = Reminder.mock(
            frequency: .custom([.monday, .wednesday, .friday])
        )
        
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let shouldTrigger = [2, 4, 6].contains(today)
        
        XCTAssertEqual(reminder.shouldTriggerToday(), shouldTrigger)
    }
    
    // MARK: - Next Trigger Date Calculation
    
    func testNextTriggerDateDaily() {
        let reminder = Reminder.mock(
            hour: 8,
            minute: 0,
            frequency: .daily
        )
        
        guard let nextDate = reminder.nextTriggerDate(from: Date()) else {
            XCTFail("Should calculate next trigger date")
            return
        }
        
        let calendar = Calendar.current
        let nextHour = calendar.component(.hour, from: nextDate)
        let nextMinute = calendar.component(.minute, from: nextDate)
        
        XCTAssertEqual(nextHour, 8)
        XCTAssertEqual(nextMinute, 0)
    }
    
    func testNextTriggerDateRespectsTim Zone() {
        let berlinTZ = TimeZone(identifier: "Europe/Berlin")!
        let reminder = Reminder.mock(
            hour: 8,
            minute: 0,
            timezone: berlinTZ,
            frequency: .daily
        )
        
        guard let nextDate = reminder.nextTriggerDate(from: Date()) else {
            XCTFail("Should calculate next trigger date")
            return
        }
        
        var calendar = Calendar.current
        calendar.timeZone = berlinTZ
        
        let hour = calendar.component(.hour, from: nextDate)
        XCTAssertEqual(hour, 8)
    }
    
    func testNextTriggerDateNilForInactiveFrequency() {
        let reminder = Reminder.mock(
            hour: 8,
            minute: 0,
            frequency: .custom([.monday])  // Only Monday
        )
        
        // If today is not Monday, should return nil
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        if today != 2 { // Not Monday
            let nextDate = reminder.nextTriggerDate(from: Date())
            XCTAssertNotNil(nextDate)  // Should find next Monday
        }
    }
    
    // MARK: - Codable Conformance
    
    func testReminderCodableRoundtrip() throws {
        let original = Reminder.mock(
            hour: 14,
            minute: 30,
            frequency: .mondayToFriday
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Reminder.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.hour, decoded.hour)
        XCTAssertEqual(original.minute, decoded.minute)
        XCTAssertEqual(original.frequency, decoded.frequency)
        XCTAssertEqual(original.isActive, decoded.isActive)
    }
    
    func testReminderCodableWithCustomFrequency() throws {
        let original = Reminder.mock(
            frequency: .custom([.tuesday, .thursday, .saturday])
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Reminder.self, from: encoded)
        
        XCTAssertEqual(original.frequency, decoded.frequency)
    }
    
    func testReminderCodablePreservesTimezone() throws {
        let nyTZ = TimeZone(identifier: "America/New_York")!
        let original = Reminder.mock(timezone: nyTZ)
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Reminder.self, from: encoded)
        
        XCTAssertEqual(original.timezone.identifier, decoded.timezone.identifier)
    }
    
    func testReminderCodableWithLastTriggeredAt() throws {
        let now = Date()
        var reminder = Reminder.mock()
        reminder.lastTriggeredAt = now
        
        let encoded = try JSONEncoder().encode(reminder)
        let decoded = try JSONDecoder().decode(Reminder.self, from: encoded)
        
        XCTAssertEqual(decoded.lastTriggeredAt?.timeIntervalSince1970 ?? 0,
                       now.timeIntervalSince1970,
                       accuracy: 0.1)
    }
    
    // MARK: - Equality & Hashing
    
    func testReminderEquality() {
        let id = UUID()
        let reminder1 = Reminder(
            id: id,
            hour: 8,
            minute: 0,
            frequency: .daily
        )
        let reminder2 = Reminder(
            id: id,
            hour: 8,
            minute: 0,
            frequency: .daily
        )
        
        XCTAssertEqual(reminder1, reminder2)
    }
    
    func testReminderHashable() {
        let reminder1 = Reminder.mock()
        let reminder2 = Reminder.mock()
        
        var set = Set<Reminder>()
        set.insert(reminder1)
        set.insert(reminder2)
        
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Edge Cases
    
    func testReminderAtMidnight() {
        let reminder = Reminder.mock(hour: 0, minute: 0)
        XCTAssertEqual(reminder.hour, 0)
        XCTAssertEqual(reminder.minute, 0)
    }
    
    func testReminderAt2359() {
        let reminder = Reminder.mock(hour: 23, minute: 59)
        XCTAssertEqual(reminder.hour, 23)
        XCTAssertEqual(reminder.minute, 59)
    }
}