import XCTest
@testable import YourAppModule

// MARK: - Mock Services

class MockUserService {
    var examDate: Date?
}

class MockProgressService {
    var overallReadiness: Int = 0
}

class MockNotificationScheduler {
    var shouldThrow: Bool = false
    var isPendingFlag: Bool = false
    
    func schedule(at time: DateComponents) async throws {
        if shouldThrow {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
    }
}

// MARK: - DailyReminderViewModelTests

class DailyReminderViewModelTests: XCTestCase {
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
    
    override func tearDown() {
        sut = nil
        mockUserService = nil
        mockProgressService = nil
        mockNotificationScheduler = nil
        super.tearDown()
    }
}

// MARK: - Extension Tests

extension DailyReminderViewModelTests {
    
    // MARK: - Urgency Calculation
    
    func testUrgencyLevel_Critical_When3DaysRemaining() async {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 80
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert
        XCTAssertEqual(sut.urgencyLevel, .critical)
    }
    
    func testUrgencyLevel_High_When7DaysAnd40PercentReadiness() async {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 40
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert
        XCTAssertEqual(sut.urgencyLevel, .high)
    }
    
    func testUrgencyLevel_High_When5DaysEvenWith80Percent() async {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 80
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert
        XCTAssertEqual(sut.urgencyLevel, .high)
    }
    
    func testUrgencyLevel_Normal_When21DaysAnd70Percent() async {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .day, value: 21, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 70
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert
        XCTAssertEqual(sut.urgencyLevel, .normal)
    }
    
    // MARK: - Post-Exam State
    
    func testExaminationStatus_Completed_WhenExamDatePassed() async {
        // Arrange
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockUserService.examDate = pastDate
        
        // Act
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert
        XCTAssertEqual(sut.examinationStatus, .completed)
        XCTAssertTrue(sut.notificationMessage.contains("Glückwunsch"))
    }
    
    func testExaminationStatus_DoesNotUpdate_WhenExamDateIsNil() {
        // Arrange
        mockUserService.examDate = nil
        
        // Act
        let statusBefore = sut.examinationStatus
        
        // Assert
        XCTAssertEqual(statusBefore, .preparing)
    }
    
    // MARK: - Race Condition Prevention (Debouncing)
    
    func testRapidUpdates_OnlyFinalStateApplied() async {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        
        // Act - simulate rapid updates
        for i in 1...5 {
            mockProgressService.overallReadiness = i * 10
        }
        
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Assert - only final value (50) is reflected
        XCTAssertEqual(sut.readinessPct, 50)
    }
    
    // MARK: - Enable Reminder Error Handling
    
    func testEnableReminder_ThrowsError_WhenSchedulerFails() async {
        // Arrange
        mockNotificationScheduler.shouldThrow = true
        let time = DateComponents(hour: 9, minute: 0)
        
        // Act & Assert
        do {
            try await sut.enableReminder(at: time)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertFalse(sut.isReminderEnabled)
        }
    }
    
    // MARK: - Load Reminder State
    
    func testLoadReminderState_RestoresPreviouslyEnabledReminder() async {
        // Arrange
        mockNotificationScheduler.isPendingFlag = true
        
        // Act
        let newViewModel = DailyReminderViewModel(
            userService: mockUserService,
            progressService: mockProgressService,
            notificationScheduler: mockNotificationScheduler
        )
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Assert
        XCTAssertTrue(newViewModel.isReminderEnabled)
    }
}