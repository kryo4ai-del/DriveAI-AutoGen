// Tests/Unit/Models/ExamResultTests.swift
import XCTest
@testable import DriveAI

final class ExamResultTests: XCTestCase {
    
    func test_examResult_score_percentage() {
        let result = ExamResult(
            userProfileId: "user1",
            correctAnswers: 27,
            categoryScores: [:],
            timeTakenSeconds: 3600
        )
        
        XCTAssertEqual(result.score, 90.0, accuracy: 0.1)
    }
    
    func test_examResult_isPassed_with22Correct() {
        let result = ExamResult(
            userProfileId: "user1",
            correctAnswers: 22,
            categoryScores: [:],
            timeTakenSeconds: 3600
        )
        
        XCTAssertTrue(result.isPassed, "22/30 should pass")
    }
    
    func test_examResult_isPassed_with21Correct() {
        let result = ExamResult(
            userProfileId: "user1",
            correctAnswers: 21,
            categoryScores: [:],
            timeTakenSeconds: 3600
        )
        
        XCTAssertFalse(result.isPassed, "21/30 should fail")
    }
    
    func test_examResult_isPassed_with30Correct() {
        let result = ExamResult(
            userProfileId: "user1",
            correctAnswers: 30,
            categoryScores: [:],
            timeTakenSeconds: 3600
        )
        
        XCTAssertTrue(result.isPassed)
    }
    
    func test_examResult_isPassed_with0Correct() {
        let result = ExamResult(
            userProfileId: "user1",
            correctAnswers: 0,
            categoryScores: [:],
            timeTakenSeconds: 3600
        )
        
        XCTAssertFalse(result.isPassed)
    }
    
    func test_examResult_passPercentage() {
        let result = ExamResult(
            userProfileId: "user1",
            correctAnswers: 22,
            categoryScores: [:],
            timeTakenSeconds: 3600
        )
        
        let expected = (22.0 / 30.0) * 100
        XCTAssertEqual(result.passPercentage, expected, accuracy: 0.1)
    }
}