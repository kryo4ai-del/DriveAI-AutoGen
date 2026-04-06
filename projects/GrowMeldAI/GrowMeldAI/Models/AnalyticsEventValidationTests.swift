// Tests/AnalyticsEventValidationTests.swift
import XCTest

final class AnalyticsEventValidationTests: XCTestCase {
    func testQuestionAnsweredEventValidation() {
        let validEvent = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 5000,  // 5 seconds
            difficulty: .medium
        )
        XCTAssertTrue(validEvent.isValid)
        
        let invalidEventTimeSpent = AnalyticsEvent.questionAnswered(
            questionID: "q1",
            categoryID: "signs",
            isCorrect: true,
            timeSpent: 0,  // ❌ Invalid: 0ms
            difficulty: .medium
        )
        XCTAssertFalse(invalidEventTimeSpent.isValid)
    }
    
    func testExamSimulationCompletedValidation() {
        let validEvent = AnalyticsEvent.examSimulationCompleted(
            score: 25,
            maxScore: 30,
            passStatus: .passed,
            timeTaken: 1800,  // 30 min
            questionsCorrect: 25
        )
        XCTAssertTrue(validEvent.isValid)
        
        let invalidEvent = AnalyticsEvent.examSimulationCompleted(
            score: 50,  // ❌ Invalid: > maxScore
            maxScore: 30,
            passStatus: .passed,
            timeTaken: 1800,
            questionsCorrect: 25
        )
        XCTAssertFalse(invalidEvent.isValid)
    }
}