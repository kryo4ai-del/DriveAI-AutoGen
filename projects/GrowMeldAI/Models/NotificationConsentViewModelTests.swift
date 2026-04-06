import XCTest
@testable import DriveAI

@MainActor
final class NotificationConsentViewModelTests: XCTestCase {
    
    var viewModel: NotificationConsentViewModel!
    var mockPersistenceService: MockConsentPersistenceService!
    var mockPushService: MockPushNotificationService!
    var mockAnalyticsService: MockAnalyticsService!
    
    override func setUp() async throws {
        mockPersistenceService = MockConsentPersistenceService()
        mockPushService = MockPushNotificationService()
        mockAnalyticsService = MockAnalyticsService()
        
        viewModel = NotificationConsentViewModel(
            persistenceService: mockPersistenceService,
            pushNotificationService: mockPushService,
            analyticsService: mockAnalyticsService,
            examDate: Date().addingTimeInterval(32 * 24 * 3600)
        )
    }
    
    // MARK: - Happy Path Tests
    
    func testInitialStateIsPending() async throws {
        XCTAssertEqual(viewModel.consentState, .pending)
        XCTAssertFalse(viewModel.shouldShowConsentFlow)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testConsentTriggerAfterFiveCorrectAnswers() async throws {
        // Arrange
        var preference = ConsentPreference()
        preference.hasShownConsentInSession = false
        mockPersistenceService.preference = preference
        
        // Act
        await viewModel.evaluateConsentTrigger(correctAnswersThisSession: 5)
        
        // Assert
        XCTAssertTrue(viewModel.shouldShowConsentFlow)
        XCTAssertEqual(
            mockAnalyticsService.loggedEvents.last?.event,
            "consent_shown"
        )
        
        // Verify persistence updated
        let updatedPreference = await mockPersistenceService.loadPreference()
        XCTAssertTrue(updatedPreference.hasShownConsentInSession)
    }
    
    func testConsentTriggerDoesNotFireBeforeFiveAnswers() async throws {
        // Arrange
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.evaluateConsentTrigger(correctAnswersThisSession: 4)
        
        // Assert
        XCTAssertFalse(viewModel.shouldShowConsentFlow)
        XCTAssertEqual(mockAnalyticsService.loggedEvents.count, 0)
    }
    
    func testAcceptConsentRequestsPermission() async throws {
        // Arrange
        mockPushService.shouldGrantPermission = true
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.acceptConsent()
        
        // Assert
        XCTAssertEqual(viewModel.consentState, .accepted)
        XCTAssertTrue(mockPushService.permissionRequested)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testAcceptConsentSchedulesNotifications() async throws {
        // Arrange
        mockPushService.shouldGrantPermission = true
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.acceptConsent()
        
        // Assert
        XCTAssertTrue(mockPushService.testNotificationScheduled)
        XCTAssertTrue(mockPushService.examCountdownScheduled)
        XCTAssertTrue(mockPushService.dailyTipsScheduled)
    }
    
    func testAcceptConsentLogsAnalyticsEvent() async throws {
        // Arrange
        mockPushService.shouldGrantPermission = true
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.acceptConsent()
        
        // Assert
        let acceptedEvent = mockAnalyticsService.loggedEvents.first { $0.event == "consent_accepted" }
        XCTAssertNotNil(acceptedEvent)
        XCTAssertEqual(acceptedEvent?.parameters["status"] as? String, "full_success")
    }
    
    func testDeclineConsentSchedulesDeferral() async throws {
        // Arrange
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.declineConsent()
        
        // Assert
        XCTAssertEqual(viewModel.consentState, .declined)
        
        let updatedPreference = await mockPersistenceService.loadPreference()
        XCTAssertEqual(updatedPreference.state, .deferred)
        XCTAssertNotNil(updatedPreference.nextRetryDate)
        
        // Verify 3-day deferral
        let daysUntilRetry = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: updatedPreference.nextRetryDate!
        ).day ?? 0
        XCTAssertEqual(daysUntilRetry, 3)
    }
    
    // MARK: - Edge Cases
    
    func testRaceConditionPrevention_RapidTriggerCalls() async throws {
        // Arrange
        var preference = ConsentPreference()
        preference.hasShownConsentInSession = false
        mockPersistenceService.preference = preference
        
        // Act: Call trigger 3 times rapidly
        async let trigger1 = viewModel.evaluateConsentTrigger(correctAnswersThisSession: 5)
        async let trigger2 = viewModel.evaluateConsentTrigger(correctAnswersThisSession: 5)
        async let trigger3 = viewModel.evaluateConsentTrigger(correctAnswersThisSession: 5)
        
        _ = await (trigger1, trigger2, trigger3)
        
        // Assert: Modal should only show once
        let showCount = mockAnalyticsService.loggedEvents.filter { $0.event == "consent_shown" }.count
        XCTAssertEqual(showCount, 1, "Consent should only be shown once despite rapid calls")
        
        let finalPreference = await mockPersistenceService.loadPreference()
        XCTAssertTrue(finalPreference.hasShownConsentInSession)
    }
    
    func testPermissionDeniedHandling() async throws {
        // Arrange
        mockPushService.shouldGrantPermission = false
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.acceptConsent()
        
        // Assert
        XCTAssertEqual(viewModel.consentState, .permissionDenied)
        XCTAssertNotNil(viewModel.errorMessage)
        
        let loggedEvent = mockAnalyticsService.loggedEvents.first { $0.event == "system_permission_denied" }
        XCTAssertNotNil(loggedEvent)
    }
    
    func testPartialNotificationSchedulingFailure() async throws {
        // Arrange
        mockPushService.shouldGrantPermission = true
        mockPushService.examCountdownError = NSError(domain: "Test", code: -1, userInfo: nil)
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.acceptConsent()
        
        // Assert
        XCTAssertEqual(viewModel.consentState, .accepted)
        XCTAssertTrue(mockPushService.testNotificationScheduled)
        XCTAssertFalse(mockPushService.examCountdownScheduled)
        XCTAssertTrue(mockPushService.dailyTipsScheduled)
        
        let acceptedEvent = mockAnalyticsService.loggedEvents.first { $0.event == "consent_accepted" }
        XCTAssertEqual(acceptedEvent?.parameters["status"] as? String, "partial_success")
    }
    
    func testAllNotificationSchedulingFails() async throws {
        // Arrange
        mockPushService.shouldGrantPermission = true
        mockPushService.testNotificationError = NSError(domain: "Test", code: -1, userInfo: nil)
        mockPushService.examCountdownError = NSError(domain: "Test", code: -1, userInfo: nil)
        mockPushService.dailyTipsError = NSError(domain: "Test", code: -1, userInfo: nil)
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.acceptConsent()
        
        // Assert
        XCTAssertEqual(viewModel.consentState, .accepted) // State still accepted
        XCTAssertNotNil(viewModel.errorMessage)
        
        let acceptedEvent = mockAnalyticsService.loggedEvents.first { $0.event == "consent_accepted" }
        XCTAssertEqual(acceptedEvent?.parameters["status"] as? String, "full_failure")
    }
    
    func testDismissConsentSetsCorrectState() async throws {
        // Arrange
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        await viewModel.dismissConsent()
        
        // Assert
        XCTAssertEqual(viewModel.consentState, .dismissed)
        XCTAssertFalse(viewModel.shouldShowConsentFlow)
        
        let loggedEvent = mockAnalyticsService.loggedEvents.first { $0.event == "consent_dismissed" }
        XCTAssertNotNil(loggedEvent)
    }
    
    // MARK: - Re-engagement Tests
    
    func testDeferredConsentDoesNotRetriggerImmediately() async throws {
        // Arrange
        var preference = ConsentPreference()
        preference.state = .deferred
        preference.nextRetryDate = Date().addingTimeInterval(3 * 24 * 3600) // 3 days from now
        mockPersistenceService.preference = preference
        
        // Act
        await viewModel.evaluateDeferredConsent(userProgress: 20)
        
        // Assert
        XCTAssertFalse(viewModel.shouldShowConsentFlow)
    }
    
    func testDeferredConsentRetriggerAfterGracePeriod() async throws {
        // Arrange
        var preference = ConsentPreference()
        preference.state = .deferred
        preference.nextRetryDate = Date().addingTimeInterval(-1 * 3600) // 1 hour ago
        mockPersistenceService.preference = preference
        
        // Act
        await viewModel.evaluateDeferredConsent(userProgress: 20)
        
        // Assert
        XCTAssertTrue(viewModel.shouldShowConsentFlow)
        
        let retriedEvent = mockAnalyticsService.loggedEvents.first { $0.event == "consent_retried" }
        XCTAssertNotNil(retriedEvent)
        XCTAssertEqual(retriedEvent?.parameters["context"] as? String, "progress_milestone")
    }
    
    func testDeferredConsentDoesNotRetriggerWithLowProgress() async throws {
        // Arrange
        var preference = ConsentPreference()
        preference.state = .deferred
        preference.nextRetryDate = Date().addingTimeInterval(-1 * 3600) // Eligible for retry
        mockPersistenceService.preference = preference
        
        // Act
        await viewModel.evaluateDeferredConsent(userProgress: 5) // Low progress
        
        // Assert
        XCTAssertFalse(viewModel.shouldShowConsentFlow, "Should not retry with insufficient progress")
    }
    
    // MARK: - Examination Days Calculation
    
    func testExaminationDaysRemainingCalculation() async throws {
        // The viewModel should calculate days until exam
        let daysRemaining = viewModel.examinationDaysRemaining
        XCTAssertGreater(daysRemaining, 0)
        XCTAssertLessOrEqual(daysRemaining, 33) // 32 days + grace
    }
    
    // MARK: - Concurrent Operations
    
    func testLoadingStateManagement() async throws {
        // Arrange
        mockPushService.shouldGrantPermission = true
        mockPersistenceService.preference = ConsentPreference()
        
        // Act
        XCTAssertFalse(viewModel.isLoading)
        
        let acceptTask = Task {
            await viewModel.acceptConsent()
        }
        
        // Small delay to check mid-operation
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        
        _ = await acceptTask.value
        
        // Assert
        XCTAssertFalse(viewModel.isLoading, "Should clear loading state after completion")
    }
}