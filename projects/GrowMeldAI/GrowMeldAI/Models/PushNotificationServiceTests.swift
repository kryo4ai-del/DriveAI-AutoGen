// Tests/Services/PushNotificationServiceTests.swift
import XCTest
import UserNotifications
@testable import DriveAI

final class PushNotificationServiceTests: XCTestCase {
    
    var sut: PushNotificationService!
    
    override func setUp() {
        super.setUp()
        sut = PushNotificationService()
    }
    
    // MARK: - Authorization Tests
    
    @MainActor
    func testCheckAuthorizationStatus_ReturnsCurrentStatus() async {
        await sut.checkAuthorizationStatus()
        
        XCTAssertNotEqual(sut.authorizationStatus, .notDetermined)
    }
    
    @MainActor
    func testRequestUserAuthorizationSuccess() async {
        // Mock UNUserNotificationCenter
        let mockCenter = MockUNUserNotificationCenter()
        mockCenter.shouldGrantPermission = true
        
        // Note: In real tests, you'd use Dependency Injection
        // This is a simplified example
        
        let granted = await sut.requestUserAuthorization()
        
        XCTAssertTrue(granted)
        await sut.checkAuthorizationStatus()
    }
    
    @MainActor
    func testRequestUserAuthorizationDenied() async {
        let mockCenter = MockUNUserNotificationCenter()
        mockCenter.shouldGrantPermission = false
        
        let granted = await sut.requestUserAuthorization()
        
        XCTAssertFalse(granted)
        XCTAssertEqual(sut.lastError, .systemAuthorizationDenied)
    }
    
    // MARK: - Notification Scheduling Tests
    
    @MainActor
    func testScheduleQuizReminderNotification_ValidInput() async throws {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        try await sut.scheduleQuizReminderNotification(
            for: "Verkehrszeichen",
            at: dateComponents
        )
        
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        XCTAssertGreaterThan(pending.count, 0)
        
        // Cleanup
        await sut.cancelAllNotifications()
    }
    
    @MainActor
    func testScheduleQuizReminderNotification_NotificationContent() async throws {
        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 30
        
        try await sut.scheduleQuizReminderNotification(
            for: "Vorfahrtsregeln",
            at: dateComponents
        )
        
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let request = pending.first { $0.identifier.contains("quiz-reminder") }
        
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.content.title.contains("Vorfahrtsregeln") ?? false)
        XCTAssertTrue(request?.content.body.contains("Quiz") ?? false)
        
        // Cleanup
        await sut.cancelAllNotifications()
    }
    
    @MainActor
    func testScheduleQuizReminderNotification_DifferentCategories() async throws {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        try await sut.scheduleQuizReminderNotification(
            for: "Kategorie A",
            at: dateComponents
        )
        
        try await sut.scheduleQuizReminderNotification(
            for: "Kategorie B",
            at: dateComponents
        )
        
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        XCTAssertEqual(pending.count, 2)
        
        // Cleanup
        await sut.cancelAllNotifications()
    }
    
    @MainActor
    func testScheduleStreakMotivationNotification() async throws {
        try await sut.scheduleStreakMotivationNotification(streakDays: 7)
        
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let streakRequest = pending.first { $0.identifier.contains("streak") }
        
        XCTAssertNotNil(streakRequest)
        XCTAssertTrue(streakRequest?.content.title.contains("7") ?? false)
        
        // Cleanup
        await sut.cancelAllNotifications()
    }
    
    @MainActor
    func testCancelNotifications_RemovesSpecificNotification() async throws {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        try await sut.scheduleQuizReminderNotification(
            for: "Test",
            at: dateComponents
        )
        
        var pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let identifier = pending.first?.identifier ?? ""
        XCTAssertFalse(identifier.isEmpty)
        
        sut.cancelNotifications(for: identifier)
        
        pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        XCTAssertEqual(pending.count, 0)
    }
    
    @MainActor
    func testCancelAllNotifications() async throws {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        try await sut.scheduleQuizReminderNotification(
            for: "Test1",
            at: dateComponents
        )
        try await sut.scheduleQuizReminderNotification(
            for: "Test2",
            at: dateComponents
        )
        
        sut.cancelAllNotifications()
        
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        XCTAssertEqual(pending.count, 0)
    }
}