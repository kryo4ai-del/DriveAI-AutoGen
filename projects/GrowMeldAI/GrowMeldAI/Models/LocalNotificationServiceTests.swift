import XCTest
import UserNotifications
@testable import DriveAI

final class LocalNotificationServiceTests: XCTestCase {
    var sut: LocalNotificationService!
    var mockNotificationCenter: MockUNNotificationCenter!
    
    override func setUp() {
        super.setUp()
        mockNotificationCenter = MockUNNotificationCenter()
        sut = LocalNotificationService(notificationCenter: mockNotificationCenter)
    }
    
    override func tearDown() {
        sut = nil
        mockNotificationCenter = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_scheduleReminder_withValidInput_succeeds() async throws {
        // Arrange
        let time = DateComponents(hour: 19, minute: 30)
        let message = "Test reminder"
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(time: time, message: message)
        
        // Assert
        XCTAssertEqual(mockNotificationCenter.addRequestCallCount, 1)
        let request = mockNotificationCenter.lastAddedRequest
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.content.body, message)
        XCTAssertEqual(request?.identifier, "com.driveai.daily-reminder")
    }
    
    func test_scheduleReminder_requestsNotificationPermission() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 10, minute: 0),
            message: "Test"
        )
        
        // Assert
        XCTAssertTrue(mockNotificationCenter.requestAuthorizationCalled)
    }
    
    func test_scheduleReminder_withDailyRepeat_triggersDaily() async throws {
        // Arrange
        let time = DateComponents(hour: 10, minute: 30)
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(time: time, message: "Daily task")
        
        // Assert
        let request = mockNotificationCenter.lastAddedRequest
        let trigger = request?.trigger as? UNCalendarNotificationTrigger
        XCTAssertTrue(trigger?.repeats ?? false)
        XCTAssertEqual(trigger?.dateComponents.hour, 10)
        XCTAssertEqual(trigger?.dateComponents.minute, 30)
    }
    
    func test_scheduleReminder_setsSoundDefault() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 9, minute: 0),
            message: "Alert"
        )
        
        // Assert
        let request = mockNotificationCenter.lastAddedRequest
        XCTAssertEqual(request?.content.sound, .default)
    }
    
    func test_scheduleReminder_setsBadgeNumber() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 14, minute: 0),
            message: "Badge test"
        )
        
        // Assert
        let badge = mockNotificationCenter.lastAddedRequest?.content.badge
        XCTAssertEqual(badge?.intValue, 1)
    }
    
    func test_scheduleReminder_cancelsPreviousReminders() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 10, minute: 0),
            message: "First"
        )
        try await sut.scheduleReminder(
            time: DateComponents(hour: 15, minute: 0),
            message: "Second"
        )
        
        // Assert
        XCTAssertTrue(mockNotificationCenter.removeAllCalled)
        XCTAssertEqual(mockNotificationCenter.addRequestCallCount, 2)
    }
    
    func test_cancelAllReminders_succeeds() async throws {
        // Act
        try await sut.cancelAllReminders()
        
        // Assert
        XCTAssertTrue(mockNotificationCenter.removeAllCalled)
    }
    
    func test_getScheduledReminders_returnsEmptyArray_whenNoneScheduled() async {
        // Arrange
        mockNotificationCenter.pendingRequests = []
        
        // Act
        let reminders = await sut.getScheduledReminders()
        
        // Assert
        XCTAssertTrue(reminders.isEmpty)
    }
    
    func test_getScheduledReminders_returnsScheduled() async {
        // Arrange
        let request = createMockNotificationRequest(
            identifier: "reminder-1",
            body: "Test reminder",
            hour: 19,
            minute: 0
        )
        mockNotificationCenter.pendingRequests = [request]
        
        // Act
        let reminders = await sut.getScheduledReminders()
        
        // Assert
        XCTAssertEqual(reminders.count, 1)
        XCTAssertEqual(reminders.first?.message, "Test reminder")
        XCTAssertEqual(reminders.first?.hour, 19)
    }
    
    func test_requestAuthorization_succeeds() async {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        
        // Act
        let authorized = await sut.requestAuthorization()
        
        // Assert
        XCTAssertTrue(authorized)
    }
    
    func test_getAuthorizationStatus_returnsAuthorized() async {
        // Arrange
        mockNotificationCenter.authorizationStatus = .authorized
        
        // Act
        let status = await sut.getAuthorizationStatus()
        
        // Assert
        XCTAssertEqual(status, .authorized)
    }
    
    // MARK: - Edge Cases
    
    func test_scheduleReminder_withMidnightTime_succeeds() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 0, minute: 0),
            message: "Midnight"
        )
        
        // Assert
        let trigger = mockNotificationCenter.lastAddedRequest?.trigger as? UNCalendarNotificationTrigger
        XCTAssertEqual(trigger?.dateComponents.hour, 0)
        XCTAssertEqual(trigger?.dateComponents.minute, 0)
    }
    
    func test_scheduleReminder_with2359Time_succeeds() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 23, minute: 59),
            message: "Late"
        )
        
        // Assert
        let trigger = mockNotificationCenter.lastAddedRequest?.trigger as? UNCalendarNotificationTrigger
        XCTAssertEqual(trigger?.dateComponents.hour, 23)
        XCTAssertEqual(trigger?.dateComponents.minute, 59)
    }
    
    func test_scheduleReminder_withEmptyMessage_succeeds() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 14, minute: 0),
            message: ""
        )
        
        // Assert
        let request = mockNotificationCenter.lastAddedRequest
        XCTAssertEqual(request?.content.body, "")
    }
    
    func test_scheduleReminder_withLongMessage_succeeds() async throws {
        // Arrange
        let longMessage = String(repeating: "Test ", count: 100)
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 14, minute: 0),
            message: longMessage
        )
        
        // Assert
        let request = mockNotificationCenter.lastAddedRequest
        XCTAssertEqual(request?.content.body, longMessage)
    }
    
    func test_scheduleReminder_withGermanUmlaut_succeeds() async throws {
        // Arrange
        let message = "Du bist auf 78%! 5 Minuten Theorie heute — dein Führerschein wartet nicht ewig."
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 19, minute: 0),
            message: message
        )
        
        // Assert
        let request = mockNotificationCenter.lastAddedRequest
        XCTAssertEqual(request?.content.body, message)
    }
    
    func test_scheduleReminder_multipleTimes_onlyLastOneScheduled() async throws {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        mockNotificationCenter.addRequestResult = .success(())
        
        // Act
        try await sut.scheduleReminder(
            time: DateComponents(hour: 10, minute: 0),
            message: "First"
        )
        let firstID = mockNotificationCenter.lastAddedRequest?.identifier
        
        try await sut.scheduleReminder(
            time: DateComponents(hour: 15, minute: 0),
            message: "Second"
        )
        let secondID = mockNotificationCenter.lastAddedRequest?.identifier
        
        // Assert — same identifier means overwritten
        XCTAssertEqual(firstID, secondID)
        XCTAssertEqual(firstID, "com.driveai.daily-reminder")
    }
    
    // MARK: - Failure Scenarios
    
    func test_scheduleReminder_withoutPermission_throwsError() async {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = false
        
        // Act & Assert
        do {
            try await sut.scheduleReminder(
                time: DateComponents(hour: 14, minute: 0),
                message: "Test"
            )
            XCTFail("Expected ReminderError.notificationsDenied")
        } catch ReminderError.notificationsDenied {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_scheduleReminder_withInvalidHour_throwsError() async {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        
        // Act & Assert
        do {
            try await sut.scheduleReminder(
                time: DateComponents(hour: 25, minute: 0),
                message: "Test"
            )
            XCTFail("Expected ReminderError.invalidTime")
        } catch ReminderError.invalidTime {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_scheduleReminder_withInvalidMinute_throwsError() async {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        
        // Act & Assert
        do {
            try await sut.scheduleReminder(
                time: DateComponents(hour: 14, minute: 60),
                message: "Test"
            )
            XCTFail("Expected ReminderError.invalidTime")
        } catch ReminderError.invalidTime {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_scheduleReminder_withMissingHour_throwsError() async {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        
        // Act & Assert
        do {
            try await sut.scheduleReminder(
                time: DateComponents(minute: 0),
                message: "Test"
            )
            XCTFail("Expected ReminderError.invalidTime")
        } catch ReminderError.invalidTime {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_scheduleReminder_whenAddFails_throwsError() async {
        // Arrange
        mockNotificationCenter.requestAuthorizationResult = true
        let error = NSError(domain: "NotificationError", code: -1)
        mockNotificationCenter.addRequestResult = .failure(error)
        
        // Act & Assert
        do {
            try await sut.scheduleReminder(
                time: DateComponents(hour: 14, minute: 0),
                message: "Test"
            )
            XCTFail("Expected ReminderError.failedToSchedule")
        } catch ReminderError.failedToSchedule {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func createMockNotificationRequest(
        identifier: String,
        body: String,
        hour: Int,
        minute: Int
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.body = body
        let dateComponents = DateComponents(hour: hour, minute: minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }
}