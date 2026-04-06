// Tests/PerformanceTracking/Unit/Models/PerformanceMetricsTests.swift

import XCTest
@testable import DriveAI

final class PerformanceMetricsTests: XCTestCase {
    var sut: PerformanceMetrics!
    let testCategoryId = UUID()
    
    override func setUp() {
        super.setUp()
        sut = PerformanceMetrics(categoryId: testCategoryId, categoryName: "Verkehrsschilder")
    }
    
    // MARK: - Initialization Tests
    
    func test_init_setsProperties() {
        XCTAssertEqual(sut.categoryId, testCategoryId)
        XCTAssertEqual(sut.categoryName, "Verkehrsschilder")
        XCTAssertEqual(sut.correctAnswers, 0)
        XCTAssertEqual(sut.totalAttempts, 0)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.createdAt)
    }
    
    // MARK: - Accuracy Calculation Tests
    
    func test_accuracy_withZeroAttempts_returnsZero() {
        XCTAssertEqual(sut.accuracy, 0)
    }
    
    func test_accuracy_withAllCorrect_returnsHundred() {
        sut.totalAttempts = 10
        sut.correctAnswers = 10
        XCTAssertEqual(sut.accuracy, 100)
    }
    
    func test_accuracy_withPartialCorrect_returnsWeightedPercentage() {
        sut.totalAttempts = 20
        sut.correctAnswers = 15
        XCTAssertEqual(sut.accuracy, 75)
    }
    
    func test_accuracy_withDecimalResult_roundsCorrectly() {
        sut.totalAttempts = 3
        sut.correctAnswers = 1
        XCTAssertEqual(sut.accuracy, Double(1) / 3 * 100, accuracy: 0.01)
    }
    
    // MARK: - Readiness Level Determination Tests
    
    func test_readinessLevel_below60_returnsPoor() {
        sut.totalAttempts = 10
        sut.correctAnswers = 5
        XCTAssertEqual(sut.readinessLevel, .poor)
    }
    
    func test_readinessLevel_60to79_returnsFair() {
        sut.totalAttempts = 10
        sut.correctAnswers = 7
        XCTAssertEqual(sut.readinessLevel, .fair)
    }
    
    func test_readinessLevel_80to89_returnsGood() {
        sut.totalAttempts = 10
        sut.correctAnswers = 8
        XCTAssertEqual(sut.readinessLevel, .good)
    }
    
    func test_readinessLevel_90plus_returnsExcellent() {
        sut.totalAttempts = 10
        sut.correctAnswers = 9
        XCTAssertEqual(sut.readinessLevel, .excellent)
    }
    
    // MARK: - Weak Area Detection Tests
    
    func test_isWeak_accuracy70below_and5PlusAttempts_returnsTrue() {
        sut.totalAttempts = 5
        sut.correctAnswers = 3  // 60% accuracy
        XCTAssertTrue(sut.isWeak)
    }
    
    func test_isWeak_accuracy70plus_returnsFalse() {
        sut.totalAttempts = 10
        sut.correctAnswers = 7
        XCTAssertFalse(sut.isWeak)
    }
    
    func test_isWeak_fewerThan5Attempts_returnsFalse() {
        sut.totalAttempts = 4
        sut.correctAnswers = 2  // 50% but insufficient data
        XCTAssertFalse(sut.isWeak)
    }
    
    // MARK: - Record Attempt Tests
    
    func test_recordAttempt_correct_incrementsCorrectAnswers() {
        sut.recordAttempt(correct: true)
        XCTAssertEqual(sut.correctAnswers, 1)
        XCTAssertEqual(sut.totalAttempts, 1)
    }
    
    func test_recordAttempt_correct_incrementsStreak() {
        sut.recordAttempt(correct: true)
        sut.recordAttempt(correct: true)
        XCTAssertEqual(sut.currentStreak, 2)
    }
    
    func test_recordAttempt_incorrect_resetsStreak() {
        sut.recordAttempt(correct: true)
        sut.recordAttempt(correct: true)
        sut.recordAttempt(correct: false)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertEqual(sut.longestStreak, 2)
        XCTAssertEqual(sut.totalAttempts, 3)
    }
    
    func test_recordAttempt_tracksLongestStreak() {
        // Streak: 3
        for _ in 0..<3 { sut.recordAttempt(correct: true) }
        sut.recordAttempt(correct: false)
        
        // Streak: 2
        for _ in 0..<2 { sut.recordAttempt(correct: true) }
        
        XCTAssertEqual(sut.longestStreak, 3)
        XCTAssertEqual(sut.currentStreak, 2)
    }
    
    func test_recordAttempt_updatesLastAttemptDate() {
        let beforeDate = Date()
        sut.recordAttempt(correct: true)
        let afterDate = Date()
        
        XCTAssertGreaterThanOrEqual(sut.lastAttemptDate ?? Date(distantPast: ), beforeDate)
        XCTAssertLessThanOrEqual(sut.lastAttemptDate ?? Date(distantFuture: ), afterDate)
    }
    
    func test_recordAttempt_multipleCalls_correctlyAccumulates() {
        for i in 0..<100 {
            sut.recordAttempt(correct: i % 3 != 0)  // 66% correct
        }
        
        XCTAssertEqual(sut.totalAttempts, 100)
        XCTAssertEqual(sut.correctAnswers, 67)
        XCTAssertEqual(sut.accuracy, 67, accuracy: 0.1)
    }
}