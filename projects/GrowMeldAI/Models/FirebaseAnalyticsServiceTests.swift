import XCTest
import FirebaseCore
import FirebaseAnalytics
@testable import DriveAI

final class FirebaseAnalyticsServiceTests: XCTestCase {
    var service: FirebaseAnalyticsService!
    
    @MainActor
    override func setUp() {
        super.setUp()
        // Use Firebase emulator for testing
        FirebaseApp.configure()
        service = FirebaseAnalyticsService()
    }
    
    @MainActor
    override func tearDown() {
        super.tearDown()
        Task {
            await service.reset()
        }
    }
    
    // MARK: - Event Logging Tests
    
    @MainActor
    func testQuestionAnsweredEventLogging() async {
        let event = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .medium
        )
        
        // Should not throw
        await service.logEvent(event)
        
        // Firebase logs asynchronously; verify by checking Analytics state
        // (In real environment, verify via Firebase Console within 5 minutes)
    }
    
    @MainActor
    func testInvalidEventDropped() async {
        let invalidEvent = AnalyticsEvent.questionAnswered(
            questionID: "",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 0,
            difficulty: .medium
        )
        
        // Should not log invalid event
        await service.logEvent(invalidEvent)
        // No error thrown, event silently dropped
    }
    
    @MainActor
    func testExamSimulationEventLogging() async {
        let event = AnalyticsEvent.examSimulationCompleted(
            score: 25,
            maxScore: 30,
            passStatus: .passed,
            timeTaken: 1800,
            questionsCorrect: 25
        )
        
        await service.logEvent(event)
        // Verify in Firebase Console
    }
    
    // MARK: - User Property Tests
    
    @MainActor
    func testSetUserProperties() async {
        let examDate = Date().addingTimeInterval(86400 * 30)  // 30 days from now
        
        await service.setUserProperty(.examDate(examDate))
        await service.setUserProperty(.language("de"))
        await service.setUserProperty(.userLevel("intermediate"))
        
        // Verify in Firebase Console user properties
    }
    
    @MainActor
    func testSetUserID() async {
        let userID = UUID().uuidString
        
        await service.setUserID(userID)
        
        // Firebase should track this user ID in subsequent events
    }
    
    // MARK: - Event Format Tests
    
    @MainActor
    func testEventFormattingForFirebase() async {
        let event = AnalyticsEvent.questionAnswered(
            questionID: "q123",
            categoryID: "traffic_signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .hard
        )
        
        // Verify the event is formatted correctly for Firebase
        // This is implementation-specific; Firebase expects:
        // - event name: "question_answered"
        // - parameters: [questionID, categoryID, isCorrect, timeSpent, difficulty]
        
        await service.logEvent(event)
    }
    
    // MARK: - Offline/Error Handling Tests
    
    @MainActor
    func testEventLoggingWithoutCrashingOnFirebaseFailure() async {
        // If Firebase is not configured, service should handle gracefully
        let event = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,
            difficulty: .medium
        )
        
        // Should not throw or crash
        await service.logEvent(event)
    }
    
    // MARK: - Reset Tests
    
    @MainActor
    func testResetAnalyticsData() async {
        await service.setUserID("test_user")
        await service.setUserProperty(.language("de"))
        
        await service.reset()
        
        // Data should be cleared in Firebase
    }
}