// Tests/ViewModels/DailyReminderViewModelTests.swift
import XCTest
@testable import DriveAI

@MainActor
final class DailyReminderViewModelTests: XCTestCase {
    var sut: DailyReminderViewModel!
    var mockUserService: MockUserService!
    var mockProgressService: MockProgressService!
    var mockNotificationScheduler: MockNotificationScheduler!
    
    override func setUp() {
        super.setUp()
        mockUserService = MockUserService()
        mockProgressService = MockProgressService()
        mockNotificationScheduler = MockNotificationScheduler()
        
        sut = DailyReminderViewModel(
            userService: mockUserService,
            progressService: mockProgressService,
            notificationScheduler: mockNotificationScheduler
        )
    }
    
    // MARK: - Happy Path
    
    func testInitialState_WithNoExamDate() {
        XCTAssertEqual(sut.daysUntilExam, 0)
        XCTAssertEqual(sut.readinessPct, 0)
        XCTAssertEqual(sut.examinationStatus, .preparing)
    }
    
    func testUpdateState_With7DaysRemaining_50Percent() async {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 50
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)  // Wait for debounce
        
        // Assert
        XCTAssertEqual(sut.daysUntilExam, 7)
        XCTAssertEqual(sut.readinessPct, 50)
        XCTAssertEqual(sut.urgencyLevel, .normal)
        XCTAssertTrue(sut.notificationMessage.contains("50"))
    }
    
    func testUpdateState_With2DaysRemaining_30Percent() async {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 30
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert
        XCTAssertEqual(sut.daysUntilExam, 2)
        XCTAssertEqual(sut.urgencyLevel, .critical)
        XCTAssertTrue(sut.notificationMessage.contains("2"))
    }
    
    func testUpdateState_WithZeroDays_ExamToday() async {
        // Arrange
        let examDate = Date()
        mockUserService.examDate = examDate
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert
        XCTAssertEqual(sut.daysUntilExam, 0)
        XCTAssertEqual(sut.examinationStatus, .today)
    }
    
    func testEnableReminder_SchedulesNotification() async throws {
        // Arrange
        let time = DateComponents(hour: 9, minute: 0)
        
        // Act
        try await sut.enableReminder(at: time)
        
        // Assert
        XCTAssertTrue(sut.isReminderEnabled)
        XCTAssertTrue(mockNotificationScheduler.scheduleWasCalled)
        XCTAssertEqual(mockNotificationScheduler.lastScheduledTime, time)
        XCTAssertTrue(mockUserService.reminderEnabledFlag)
    }
    
    func testDisableReminder_CancelsNotification() {
        // Arrange
        sut.isReminderEnabled = true
        
        // Act
        sut.disableReminder()
        
        // Assert
        XCTAssertFalse(sut.isReminderEnabled)
        XCTAssertTrue(mockNotificationScheduler.cancelWasCalled)
        XCTAssertFalse(mockUserService.reminderEnabledFlag)
    }
}