import XCTest
@testable import DriveAI

final class ExamRecordTests: XCTestCase {
    
    // MARK: - Pass/Fail Determination
    
    func testPassed_TrueWhen86Percent() {
        let now = Date()
        let exam = ExamRecord(
            id: "exam-1",
            startedAt: now,
            completedAt: now.addingTimeInterval(900),
            createdAt: now,
            durationSeconds: 900,
            totalQuestions: 50,
            correctAnswers: 43,  // 86%
            categoryBreakdown: [:],
            examType: .simulation
        )
        
        XCTAssertTrue(exam.passed)
    }
    
    func testPassed_FalseWhen85Percent() {
        let now = Date()
        let exam = ExamRecord(
            id: "exam-1",
            startedAt: now,
            completedAt: now.addingTimeInterval(900),
            createdAt: now,
            durationSeconds: 900,
            totalQuestions: 50,
            correctAnswers: 42,  // 84%
            categoryBreakdown: [:],
            examType: .simulation
        )
        
        XCTAssertFalse(exam.passed)
    }
    
    // MARK: - Score Calculation
    
    func testScorePercentage_CalculatesCorrectly() {
        let now = Date()
        let exam = ExamRecord(
            id: "exam-1",
            startedAt: now,
            completedAt: now.addingTimeInterval(900),
            createdAt: now,
            durationSeconds: 900,
            totalQuestions: 30,
            correctAnswers: 27,
            categoryBreakdown: [:],
            examType: .simulation
        )
        
        XCTAssertEqual(exam.scorePercentage, 0.9, accuracy: 0.001)
    }
    
    func testDurationMinutes_CalculatesCorrectly() {
        let now = Date()
        let exam = ExamRecord(
            id: "exam-1",
            startedAt: now,
            completedAt: now.addingTimeInterval(930),  // 15.5 minutes
            createdAt: now,
            durationSeconds: 930,
            totalQuestions: 30,
            correctAnswers: 27,
            categoryBreakdown: [:],
            examType: .simulation
        )
        
        XCTAssertEqual(exam.durationMinutes, 15)
    }
}