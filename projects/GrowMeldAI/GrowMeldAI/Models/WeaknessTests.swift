// Tests/Unit/Models/WeaknessTests.swift
import XCTest
@testable import DriveAI

final class WeaknessTests: XCTestCase {
    
    // MARK: - Failure Rate Calculation
    
    func testFailureRateWithZeroAttempts() {
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 0,
            totalAttempts: 0,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: Date()
        )
        
        XCTAssertEqual(weakness.failureRate, 0)
    }
    
    func testFailureRateWithSuccessfulAttempts() {
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 3,
            totalAttempts: 10,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: Date()
        )
        
        XCTAssertEqual(weakness.failureRate, 0.3, accuracy: 0.01)
    }
    
    func testFailureRateWithAllFailures() {
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 5,
            totalAttempts: 5,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: Date()
        )
        
        XCTAssertEqual(weakness.failureRate, 1.0)
    }
    
    // MARK: - Focus Level Determination
    
    func testFocusLevelGreenWhenZeroFailures() {
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 0,
            totalAttempts: 10,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: Date()
        )
        
        XCTAssertEqual(weakness.recommendedFocusLevel, .green)
    }
    
    func testFocusLevelYellowWithLowFailureRate() {
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 2,  // 20% failure rate
            totalAttempts: 10,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: Date()
        )
        
        XCTAssertEqual(weakness.recommendedFocusLevel, .yellow)
    }
    
    func testFocusLevelOrangeWithModerateFailures() {
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 4,
            totalAttempts: 10,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: Date()
        )
        
        XCTAssertEqual(weakness.recommendedFocusLevel, .orange)
    }
    
    func testFocusLevelRedWithHighFailures() {
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 8,
            totalAttempts: 10,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: Date()
        )
        
        XCTAssertEqual(weakness.recommendedFocusLevel, .red)
    }
    
    // MARK: - Overdue Detection
    
    func testIsOverdueWhenPast() {
        let pastDate = Date().addingTimeInterval(-86400)  // Yesterday
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 1,
            totalAttempts: 5,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: pastDate
        )
        
        XCTAssertTrue(weakness.isOverdue)
    }
    
    func testIsNotOverdueWhenFuture() {
        let futureDate = Date().addingTimeInterval(86400)  // Tomorrow
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 1,
            totalAttempts: 5,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: futureDate
        )
        
        XCTAssertFalse(weakness.isOverdue)
    }
    
    // MARK: - Days Until Review
    
    func testDaysUntilReviewTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 1,
            totalAttempts: 5,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: tomorrow
        )
        
        XCTAssertEqual(weakness.daysUntilReview, 1)
    }
    
    func testDaysUntilReviewWithinWeek() {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let weakness = Weakness(
            id: "test-1",
            categoryName: "Verkehrszeichen",
            failedQuestionCount: 1,
            totalAttempts: 5,
            lastFailedDate: Date(),
            createdDate: Date(),
            nextReviewDate: nextWeek
        )
        
        XCTAssertEqual(weakness.daysUntilReview, 7)
    }
}