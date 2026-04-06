import XCTest
@testable import DriveAI

class ExamAttemptModelTests: XCTestCase {
    
    func testExamAttemptInitialization() {
        let attempt = ExamAttempt(
            score: 22,
            maxScore: 30,
            passed: true,
            timeTakenSeconds: 1200
        )
        
        XCTAssertEqual(attempt.score, 22)
        XCTAssertEqual(attempt.maxScore, 30)
        XCTAssertTrue(attempt.passed)
        XCTAssertEqual(attempt.timeTakenSeconds, 1200)
    }
    
    func testScorePercentageCalculation() {
        let attempt = ExamAttempt(
            score: 24,
            maxScore: 30,
            passed: true,
            timeTakenSeconds: 1200
        )
        
        XCTAssertEqual(attempt.scorePercentage, 80.0)
    }
    
    func testScorePercentageWhenMaxScoreIsZero() {
        let attempt = ExamAttempt(
            score: 0,
            maxScore: 0,
            passed: false,
            timeTakenSeconds: 0
        )
        
        XCTAssertEqual(attempt.scorePercentage, 0)
    }
    
    func testPassingAttempt() {
        let attempt = ExamAttempt(
            score: 23,  // >= 75% of 30
            maxScore: 30,
            passed: true,
            timeTakenSeconds: 900
        )
        
        XCTAssertTrue(attempt.passed)
    }
    
    func testFailingAttempt() {
        let attempt = ExamAttempt(
            score: 20,  // < 75% of 30
            maxScore: 30,
            passed: false,
            timeTakenSeconds: 1800
        )
        
        XCTAssertFalse(attempt.passed)
    }
    
    func testUniqueAttemptIDs() {
        let attempt1 = ExamAttempt(score: 25, maxScore: 30, passed: true, timeTakenSeconds: 1000)
        let attempt2 = ExamAttempt(score: 25, maxScore: 30, passed: true, timeTakenSeconds: 1000)
        
        XCTAssertNotEqual(attempt1.id, attempt2.id)
    }
}