import XCTest
@testable import DriveAI

final class ReminderConfigurationTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testDefaultInitialization() {
        let config = ReminderConfiguration()
        
        XCTAssertFalse(config.isEnabled)
        XCTAssertEqual(config.scheduledTime.hour, 9)
        XCTAssertEqual(config.scheduledTime.minute, 0)
        XCTAssertEqual(config.frequency, .daily)
        XCTAssertNil(config.lastFiredDate)
        XCTAssertNotNil(config.id)
        XCTAssertNotNil(config.createdAt)
    }
    
    func testCustomInitialization() {
        let time = DateComponents(hour: 18, minute: 30)
        let config = ReminderConfiguration(
            isEnabled: true,
            scheduledTime: time,
            frequency: .weekdaysOnly
        )
        
        XCTAssertTrue(config.isEnabled)
        XCTAssertEqual(config.scheduledTime.hour, 18)
        XCTAssertEqual(config.scheduledTime.minute, 30)
        XCTAssertEqual(config.frequency, .weekdaysOnly)
    }
    
    // MARK: - Time Formatting
    
    func testFormattedTimeDisplay() {
        let testCases: [(Int?, Int?, String)] = [
            (9, 0, "09:00"),
            (18, 30, "18:30"),
            (0, 0, "00:00"),
            (23, 59, "23:59"),
            (nil, nil, "00:00"),  // Defaults
        ]
        
        for (hour, minute, expected) in testCases {
            var time = DateComponents()
            time.hour = hour
            time.minute = minute
            
            let config = ReminderConfiguration(scheduledTime: time)
            XCTAssertEqual(config.formattedTime, expected, "Failed for \(hour ?? -1):\(minute ?? -1)")
        }
    }
    
    func testAccessibilityTimeFormat() {
        let testCases: [(Int?, Int?, String)] = [
            (9, 0, "neun Uhr null"),
            (18, 15, "achtzehn Uhr Viertel"),
            (12, 30, "Mittag Uhr halb"),
            (0, 0, "Mitternacht Uhr null"),
        ]
        
        for (hour, minute, expected) in testCases {
            var time = DateComponents()
            time.hour = hour
            time.minute = minute
            
            let config = ReminderConfiguration(scheduledTime: time)
            XCTAssertEqual(config.accessibilityTime, expected, "Failed for \(hour ?? -1):\(minute ?? -1)")
        }
    }
    
    // MARK: - Codable Conformance
    
    func testEncodingDecoding() throws {
        let original = ReminderConfiguration(
            isEnabled: true,
            scheduledTime: DateComponents(hour: 14, minute: 45),
            frequency: .weekdaysOnly
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ReminderConfiguration.self, from: data)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.isEnabled, decoded.isEnabled)
        XCTAssertEqual(original.scheduledTime.hour, decoded.scheduledTime.hour)
        XCTAssertEqual(original.scheduledTime.minute, decoded.scheduledTime.minute)
        XCTAssertEqual(original.frequency, decoded.frequency)
    }
    
    func testEquatableConformance() {
        let config1 = ReminderConfiguration(
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
            isEnabled: true,
            scheduledTime: DateComponents(hour: 9, minute: 0)
        )
        
        let config2 = ReminderConfiguration(
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
            isEnabled: true,
            scheduledTime: DateComponents(hour: 9, minute: 0)
        )
        
        let config3 = ReminderConfiguration(
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
            isEnabled: false,
            scheduledTime: DateComponents(hour: 9, minute: 0)
        )
        
        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }
}