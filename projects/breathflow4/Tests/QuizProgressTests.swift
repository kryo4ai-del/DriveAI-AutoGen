import XCTest
import Foundation
@testable import DriveAI

final class QuizProgressTests: XCTestCase {
    
    var testQuizId: UUID!
    
    override func setUp() {
        super.setUp()
        testQuizId = UUID()
    }
    
    // MARK: - Score Calculation
    
    func testBestScoreReturnsHighestScore() {
        var progress = QuizProgress(
            id: UUID(),
            quizId: testQuizId,
            attempts: []
        )
        
        XCTAssertEqual(progress.bestScore, 0, "Empty progress should return 0")
        
        try? progress.addAttempt(createAttempt(score: 75))
        XCTAssertEqual(progress.bestScore, 75)
        
        try? progress.addAttempt(createAttempt(score: 90))
        XCTAssertEqual(progress.bestScore, 90, "Should return highest score")
        
        try? progress.addAttempt(createAttempt(score: 85))
        XCTAssertEqual(progress.bestScore, 90, "Should still return highest")
    }
    
    // MARK: - Completion Tracking
    
    func testCompletionCountIncrementsCorrectly() {
        var progress = QuizProgress(
            id: UUID(),
            quizId: testQuizId,
            attempts: []
        )
        
        XCTAssertEqual(progress.completionCount, 0)
        
        try? progress.addAttempt(createAttempt())
        XCTAssertEqual(progress.completionCount, 1)
        
        try? progress.addAttempt(createAttempt())
        XCTAssertEqual(progress.completionCount, 2)
    }
    
    // MARK: - Review Recommendation Logic
    
    func testShouldReviewWhenScoreLessThan85Percent() {
        var progress = QuizProgress(
            id: UUID(),
            quizId: testQuizId,
            attempts: []
        )
        
        try? progress.addAttempt(createAttempt(score: 80))
        XCTAssertTrue(progress.shouldReview, "Score < 85% should recommend review")
        
        try? progress.addAttempt(createAttempt(score: 85))
        XCTAssertFalse(progress.shouldReview, "Score = 85% should not recommend review")
        
        try? progress.addAttempt(createAttempt(score: 90))
        XCTAssertFalse(progress.shouldReview, "Score > 85% should not recommend review")
    }
    
    func testShouldReviewWhenMoreThan7DaysSinceAttempt() {
        var progress = QuizProgress(
            id: UUID(),
            quizId: testQuizId,
            attempts: []
        )
        
        let eightDaysAgo = Date().addingTimeInterval(-8 * 24 * 3600)
        try? progress.addAttempt(createAttempt(score: 95, completedAt: eightDaysAgo))
        
        XCTAssertTrue(progress.shouldReview, "Should review if last attempt > 7 days ago")
    }
    
    func testShouldReviewWhenNeverAttempted() {
        let progress = QuizProgress(
            id: UUID(),
            quizId: testQuizId,
            attempts: []
        )
        
        XCTAssertTrue(progress.shouldReview, "Never attempted quiz should recommend review")
    }
    
    // MARK: - Attempt Addition & Validation
    
    func testAddAttemptValidatesBeforeAdding() {
        var progress = QuizProgress(
            id: UUID(),
            quizId: testQuizId,
            attempts: []
        )
        
        let invalidAttempt = QuizAttempt(
            id: UUID(),
            quizId: testQuizId,
            licenseType: .carB,
            score: 105,  // Invalid: > 100
            correctAnswers: 25,
            totalQuestions: 20,
            completedAt: Date(),
            userAnswers: []
        )
        
        XCTAssertThrowsError(try progress.addAttempt(invalidAttempt))
        XCTAssertEqual(progress.attempts.count, 0, "Invalid attempt should not be added")
    }
    
    // MARK: - Helpers
    
    private func createAttempt(
        score: Double = 80,
        completedAt: Date = Date()
    ) -> QuizAttempt {
        QuizAttempt(
            id: UUID(),
            quizId: testQuizId,
            licenseType: .carB,
            score: score,
            correctAnswers: Int(score / 5),
            totalQuestions: 20,
            completedAt: completedAt,
            userAnswers: []
        )
    }
}