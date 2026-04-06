import XCTest
@testable import DriveAI

final class AnalyticsServiceTests: XCTestCase {
    var mockService: MockAnalyticsService!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockService = MockAnalyticsService()
    }
    
    // MARK: - Happy Path Tests
    
    @MainActor
    func testLogEventAddsEventToQueue() async {
        let event = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .medium
        )
        
        await mockService.logEvent(event)
        
        XCTAssertEqual(mockService.loggedEvents.count, 1)
        XCTAssertEqual(mockService.loggedEvents.first as? AnalyticsEvent, event)
    }
    
    @MainActor
    func testSetUserPropertyStoresValue() async {
        let property = UserProperty.language("de")
        
        await mockService.setUserProperty(property)
        
        XCTAssertEqual(mockService.userProperties["language"], "de")
    }
    
    @MainActor
    func testSetUserIDStoresValue() async {
        let userID = UUID().uuidString
        
        await mockService.setUserID(userID)
        
        XCTAssertEqual(mockService.userID, userID)
    }
    
    // MARK: - Event Validation Tests
    
    @MainActor
    func testInvalidQuestionAnsweredEventNotLogged() async {
        let invalidEvent = AnalyticsEvent.questionAnswered(
            questionID: "",  // ❌ Empty ID
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .medium
        )
        
        // Should not log invalid event
        XCTAssertFalse(invalidEvent.isValid)
    }
    
    @MainActor
    func testQuestionAnsweredTimeSpentValidation() async {
        // Valid: 1ms to 10min
        let validEvent = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .medium
        )
        XCTAssertTrue(validEvent.isValid)
        
        // Invalid: 0ms
        let zeroTimeEvent = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 0,
            difficulty: .medium
        )
        XCTAssertFalse(zeroTimeEvent.isValid)
        
        // Invalid: > 10min (600,000ms)
        let excessiveTimeEvent = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 601_000,
            difficulty: .medium
        )
        XCTAssertFalse(excessiveTimeEvent.isValid)
    }
    
    @MainActor
    func testExamSimulationCompletedValidation() async {
        // Valid case
        let validEvent = AnalyticsEvent.examSimulationCompleted(
            score: 25,
            maxScore: 30,
            passStatus: .passed,
            timeTaken: 1800,
            questionsCorrect: 25
        )
        XCTAssertTrue(validEvent.isValid)
        
        // Invalid: score > maxScore
        let invalidScoreEvent = AnalyticsEvent.examSimulationCompleted(
            score: 50,
            maxScore: 30,
            passStatus: .passed,
            timeTaken: 1800,
            questionsCorrect: 25
        )
        XCTAssertFalse(invalidScoreEvent.isValid)
        
        // Invalid: questionsCorrect > maxScore
        let invalidCorrectEvent = AnalyticsEvent.examSimulationCompleted(
            score: 25,
            maxScore: 30,
            passStatus: .passed,
            timeTaken: 1800,
            questionsCorrect: 35
        )
        XCTAssertFalse(invalidCorrectEvent.isValid)
        
        // Invalid: timeTaken > 5 hours
        let excessiveTimeEvent = AnalyticsEvent.examSimulationCompleted(
            score: 25,
            maxScore: 30,
            passStatus: .passed,
            timeTaken: 20_000,  // > 18,000s (5 hours)
            questionsCorrect: 25
        )
        XCTAssertFalse(excessiveTimeEvent.isValid)
    }
    
    @MainActor
    func testStreakMilestoneValidation() async {
        // Valid: streak between 1-365
        let validEvent = AnalyticsEvent.streakMilestoneReached(
            streakCount: 7,
            category: "signs"
        )
        XCTAssertTrue(validEvent.isValid)
        
        // Invalid: streak = 0
        let zeroStreakEvent = AnalyticsEvent.streakMilestoneReached(
            streakCount: 0,
            category: "signs"
        )
        XCTAssertFalse(zeroStreakEvent.isValid)
        
        // Invalid: streak > 365
        let excessiveStreakEvent = AnalyticsEvent.streakMilestoneReached(
            streakCount: 366,
            category: "signs"
        )
        XCTAssertFalse(excessiveStreakEvent.isValid)
        
        // Invalid: empty category
        let emptyCategoryEvent = AnalyticsEvent.streakMilestoneReached(
            streakCount: 7,
            category: ""
        )
        XCTAssertFalse(emptyCategoryEvent.isValid)
    }
    
    @MainActor
    func testProfileCountdownValidation() async {
        // Valid: 0-365 days
        let validEvent = AnalyticsEvent.profileViewedExamCountdown(daysUntilExam: 30)
        XCTAssertTrue(validEvent.isValid)
        
        // Invalid: negative days
        let negativeDaysEvent = AnalyticsEvent.profileViewedExamCountdown(daysUntilExam: -5)
        XCTAssertFalse(negativeDaysEvent.isValid)
        
        // Invalid: > 365 days
        let excessiveDaysEvent = AnalyticsEvent.profileViewedExamCountdown(daysUntilExam: 400)
        XCTAssertFalse(excessiveDaysEvent.isValid)
    }
    
    // MARK: - Concurrent Event Logging Tests
    
    @MainActor
    func testConcurrentEventLogging() async {
        let events = (0..<10).map { i in
            AnalyticsEvent.questionAnswered(
                questionID: "q\(i)",
                categoryID: "signs",
                isCorrect: i % 2 == 0,
                timeSpent: 3000,
                difficulty: .medium
            )
        }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for event in events {
                group.addTask {
                    await self.mockService.logEvent(event)
                }
            }
            try await group.waitForAll()
        }
        
        XCTAssertEqual(mockService.loggedEvents.count, 10)
    }
    
    // MARK: - Reset Tests
    
    @MainActor
    func testResetClearsAllData() async {
        await mockService.logEvent(.userOnboardingStarted)
        await mockService.setUserID("user123")
        await mockService.setUserProperty(.language("de"))
        
        await mockService.reset()
        
        XCTAssertTrue(mockService.loggedEvents.isEmpty)
        XCTAssertTrue(mockService.userProperties.isEmpty)
        XCTAssertNil(mockService.userID)
    }
    
    // MARK: - Helper Method Tests
    
    @MainActor
    func testEventCountMatchingPredicate() async {
        await mockService.logEvent(.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .medium
        ))
        await mockService.logEvent(.questionAnswered(
            questionID: "q2",
            categoryID: "signs",
            isCorrect: false,
            timeSpent: 3000,
            difficulty: .easy
        ))
        await mockService.logEvent(.categoryBrowsed(categoryID: "c1", categoryName: "Signs"))
        
        let correctAnswerCount = mockService.eventCount { event in
            if case .questionAnswered(_, _, let isCorrect, _, _) = event {
                return isCorrect
            }
            return false
        }
        
        XCTAssertEqual(correctAnswerCount, 1)
    }
    
    @MainActor
    func testLastEventMatching() async {
        await mockService.logEvent(.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .medium
        ))
        await mockService.logEvent(.categoryBrowsed(categoryID: "c1", categoryName: "Signs"))
        await mockService.logEvent(.questionAnswered(
            questionID: "q2",
            categoryID: "signs",
            isCorrect: false,
            timeSpent: 3000,
            difficulty: .easy
        ))
        
        let lastQuestionEvent = mockService.lastEvent { event in
            if case .questionAnswered = event {
                return true
            }
            return false
        }
        
        if case .questionAnswered(let qID, _, _, _, _) = lastQuestionEvent {
            XCTAssertEqual(qID, "q2")
        } else {
            XCTFail("Expected questionAnswered event")
        }
    }
}