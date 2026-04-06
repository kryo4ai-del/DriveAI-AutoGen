class ReminderSchedulerTests: XCTestCase {
    var scheduler: ReminderScheduler!
    var mockNotificationCenter: MockUNUserNotificationCenter!
    var mockPersistence: MockReminderPersistenceService!
    
    func testScheduleReminderWithValidTime() async throws {
        // Arrange
        let config = ReminderConfiguration(
            isEnabled: true,
            scheduledTime: DateComponents(hour: 9, minute: 30),
            frequency: .daily
        )
        
        // Act
        try await scheduler.scheduleReminder(config)
        
        // Assert
        XCTAssertEqual(mockNotificationCenter.addWasCalled, true)
    }
    
    func testScheduleReminderThrowsWhenPermissionDenied() async {
        // Arrange
        mockNotificationCenter.authorizationStatus = .denied
        let config = ReminderConfiguration(isEnabled: true)
        
        // Act & Assert
        await XCTAssertThrowsError(
            try await scheduler.scheduleReminder(config),
            throws: ReminderError.permissionDenied
        )
    }
}