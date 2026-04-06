// Tests/Unit/TrialCoordinatorTests.swift
final class TrialCoordinatorTests: XCTestCase {
    var coordinator: TrialCoordinator!
    var mockPersistence: MockTrialPersistenceService!
    
    override func setUp() {
        mockPersistence = MockTrialPersistenceService()
        coordinator = TrialCoordinator(persistence: mockPersistence)
    }
    
    // Happy path
    func testRecordQuestionWithinQuota() async throws {
        coordinator.journey = TrialJourney(
            daysRemaining: 7,
            questionsAnsweredToday: 9,
            examDate: .now.addingTimeInterval(7 * 86400)
        )
        
        try await coordinator.recordQuestion(answered: true)
        
        XCTAssertEqual(coordinator.journey.questionsAnsweredToday, 10)
    }
    
    // Boundary
    func testRecordQuestionExceedsQuota() async throws {
        coordinator.journey = TrialJourney(
            daysRemaining: 7,
            questionsAnsweredToday: 10,
            examDate: .now.addingTimeInterval(7 * 86400)
        )
        
        await XCTAssertThrowsError(
            try await coordinator.recordQuestion(answered: true)
        ) { error in
            XCTAssertEqual(error as? TrialError, .quotaExceeded(remaining: 0))
        }
    }
    
    // Midnight reset
    func testDailyQuotaResetsAtMidnight() async throws {
        // Mock time crossing midnight
        // Assert quotaAnsweredToday resets to 0
    }
}