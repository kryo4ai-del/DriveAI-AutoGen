// Tests/Domain/Models/ReadinessIndicatorTests.swift
import XCTest
@testable import BreathFlow3

final class ReadinessIndicatorTests: XCTestCase {
    
    func testStatusPriorityOrdering() {
        let ready = ReadinessIndicator.Status.ready
        let almostReady = ReadinessIndicator.Status.almostReady
        let notReady = ReadinessIndicator.Status.notReady
        let notStarted = ReadinessIndicator.Status.notStarted
        
        XCTAssertLessThan(ready.priority, almostReady.priority)
        XCTAssertLessThan(almostReady.priority, notReady.priority)
        XCTAssertLessThan(notReady.priority, notStarted.priority)
    }
    
    func testTrafficLightColors() {
        let readyIndicator = ReadinessIndicator(
            exerciseId: UUID(),
            status: .ready,
            completionPercentage: 100,
            sessionsRemaining: 0,
            recommendedNextStep: "Next level",
            confidenceScore: 90
        )
        
        XCTAssertEqual(readyIndicator.trafficLightEmoji, "🟢")
        
        let almostReadyIndicator = ReadinessIndicator(
            exerciseId: UUID(),
            status: .almostReady,
            completionPercentage: 75,
            sessionsRemaining: 1,
            recommendedNextStep: "One more session",
            confidenceScore: 75
        )
        
        XCTAssertEqual(almostReadyIndicator.trafficLightEmoji, "🟡")
        
        let notReadyIndicator = ReadinessIndicator(
            exerciseId: UUID(),
            status: .notReady,
            completionPercentage: 40,
            sessionsRemaining: 3,
            recommendedNextStep: "Practice more",
            confidenceScore: 50
        )
        
        XCTAssertEqual(notReadyIndicator.trafficLightEmoji, "🔴")
    }
    
    func testReadinessEquality() {
        let id = UUID()
        let indicator1 = ReadinessIndicator(
            exerciseId: id,
            status: .almostReady,
            completionPercentage: 75,
            sessionsRemaining: 1,
            recommendedNextStep: "One more",
            confidenceScore: 75
        )
        
        let indicator2 = ReadinessIndicator(
            exerciseId: id,
            status: .almostReady,
            completionPercentage: 75,
            sessionsRemaining: 1,
            recommendedNextStep: "One more",
            confidenceScore: 75
        )
        
        XCTAssertEqual(indicator1, indicator2)
    }
}