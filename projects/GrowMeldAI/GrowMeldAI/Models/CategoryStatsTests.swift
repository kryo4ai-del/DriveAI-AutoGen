import XCTest
@testable import DriveAI

final class CategoryStatsTests: XCTestCase {
    var sut: CategoryStats!
    let today = Date()
    
    override func setUp() {
        super.setUp()
        sut = CategoryStats(id: "test_category")
    }
    
    // MARK: - Initialization
    
    func testInitialization_setsDefaults() {
        XCTAssertEqual(sut.id, "test_category")
        XCTAssertEqual(sut.questionsAnswered, 0)
        XCTAssertEqual(sut.correctAnswers, 0)
        XCTAssertEqual(sut.confidenceScore, 0.0)
    }
    
    // MARK: - Accuracy Calculation
    
    func testAccuracyRate_zeroWhenNoAnswers() {
        XCTAssertEqual(sut.accuracyRate, 0.0)
    }
    
    func testAccuracyRate_calculatesCorrectly() {
        sut = CategoryStats(id: "test", questionsAnswered: 10, correctAnswers: 7)
        XCTAssertEqual(sut.accuracyRate, 0.7)
    }
    
    func testAccuracyRate_perfect() {
        sut = CategoryStats(id: "test", questionsAnswered: 5, correctAnswers: 5)
        XCTAssertEqual(sut.accuracyRate, 1.0)
    }
    
    // MARK: - Review Status
    
    func testNeedsReview_true_whenConfidenceBelowThreshold() {
        sut = CategoryStats(
            id: "test",
            questionsAnswered: 10,
            correctAnswers: 5,
            lastPracticedDate: today
        )
        sut.confidenceScore = 0.60  // Below 0.65 threshold
        XCTAssertTrue(sut.needsReview)
    }
    
    func testNeedsReview_true_whenNotPracticedInDays() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        sut = CategoryStats(
            id: "test",
            questionsAnswered: 10,
            correctAnswers: 8,
            lastPracticedDate: threeDaysAgo
        )
        sut.confidenceScore = 0.90  // High confidence
        XCTAssertTrue(sut.needsReview)  // Still needs review due to recency
    }
    
    func testNeedsReview_false_whenRecentAndConfident() {
        sut = CategoryStats(
            id: "test",
            questionsAnswered: 10,
            correctAnswers: 9,
            lastPracticedDate: today
        )
        sut.confidenceScore = 0.80
        XCTAssertFalse(sut.needsReview)
    }
    
    // MARK: - Recency Calculation
    
    func testDaysSinceLastPractice_maxIntWhenNeverPracticed() {
        XCTAssertEqual(sut.daysSinceLastPractice, Int.max)
    }
    
    func testDaysSinceLastPractice_zeroWhenToday() {
        sut = CategoryStats(id: "test", lastPracticedDate: today)
        XCTAssertEqual(sut.daysSinceLastPractice, 0)
    }
    
    func testDaysSinceLastPractice_calculatesCorrectly() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        sut = CategoryStats(id: "test", lastPracticedDate: fiveDaysAgo)
        XCTAssertEqual(sut.daysSinceLastPractice, 5)
    }
    
    // MARK: - Forgetting Curve Risk
    
    func testForgettingCurveRisk_highWhenLowConfidenceRecent() {
        sut = CategoryStats(id: "test", lastPracticedDate: today)
        sut.confidenceScore = 0.30
        
        let risk = sut.forgettingCurveRisk
        XCTAssertGreaterThan(risk, 0.5)
    }
    
    func testForgettingCurveRisk_decaysOverTime() {
        sut.confidenceScore = 0.50
        
        let today = CategoryStats(id: "test", lastPracticedDate: Date(), confidenceScore: 0.50)
        let fiveDaysAgo = CategoryStats(
            id: "test",
            lastPracticedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            confidenceScore: 0.50
        )
        
        // Risk decays as time passes (exponential decay in forgetting curve)
        XCTAssertLessThan(today.forgettingCurveRisk, fiveDaysAgo.forgettingCurveRisk)
    }
    
    // MARK: - Record Answers
    
    func testRecordAnswers_updatesCountersAndDates() {
        sut.recordAnswers(correct: 7, total: 10)
        
        XCTAssertEqual(sut.questionsAnswered, 10)
        XCTAssertEqual(sut.correctAnswers, 7)
        XCTAssertNotNil(sut.lastPracticedDate)
        XCTAssert(Calendar.current.isDateInToday(sut.lastPracticedDate!))
    }
    
    func testRecordAnswers_accumulatesMultipleSessions() {
        sut.recordAnswers(correct: 7, total: 10)
        sut.recordAnswers(correct: 8, total: 10)
        
        XCTAssertEqual(sut.questionsAnswered, 20)
        XCTAssertEqual(sut.correctAnswers, 15)
    }
    
    // MARK: - Comparable Protocol
    
    func testComparable_sortsByForgettingCurveRisk() {
        let urgent = CategoryStats(
            id: "urgent",
            questionsAnswered: 10,
            correctAnswers: 3,
            lastPracticedDate: Calendar.current.date(byAdding: .day, value: -7, to: today)!
        )
        
        let notUrgent = CategoryStats(
            id: "recent",
            questionsAnswered: 10,
            correctAnswers: 9,
            lastPracticedDate: today
        )
        
        let sorted = [notUrgent, urgent].sorted(by: <)
        XCTAssertEqual(sorted.first?.id, "urgent")
    }
}