import XCTest
@testable import DriveAI

final class RetentionEngineTests: XCTestCase {
    
    var engine: RetentionEngine!
    
    override func setUp() {
        super.setUp()
        engine = RetentionEngine()
    }
    
    // MARK: - SM-2 Algorithm
    
    func testFirstCorrectAnswerGives3Days() {
        // SM-2: First success interval is always 3 days
        let interval = engine.calculateNextInterval(
            currentInterval: 0,
            easeFactor: 2.5,
            quality: 5  // Perfect
        )
        
        XCTAssertEqual(interval, 3)
    }
    
    func testIncorrectAnswerResetsTo1Day() {
        // Wrong answer always resets
        let interval = engine.calculateNextInterval(
            currentInterval: 10,
            easeFactor: 2.5,
            quality: 2  // Incorrect
        )
        
        XCTAssertEqual(interval, 1)
    }
    
    func testQualityBelowThresholdResetsInterval() {
        // Quality 0-2 = failed, reset to 1
        for quality in 0...2 {
            let interval = engine.calculateNextInterval(
                currentInterval: 7,
                easeFactor: 2.5,
                quality: quality
            )
            XCTAssertEqual(interval, 1, "Quality \(quality) should reset to 1 day")
        }
    }
    
    func testSecondCorrectAnswerIncreases() {
        // After 3 days success, next interval = 3 * easeFactor
        let interval = engine.calculateNextInterval(
            currentInterval: 3,
            easeFactor: 2.5,
            quality: 5
        )
        
        // Approximately 3 * 2.5 = 7.5 rounded to 7
        XCTAssertGreaterThan(interval, 3)
        XCTAssertLessThanOrEqual(interval, 10)
    }
    
    func testEaseFactorAdjustmentForPerfect() {
        let newFactor = engine.adjustEaseFactor(5)
        // SM-2: EF = EF + (0.1 - (5 - 3) * 0.08)
        // = 2.5 + 0.1 = 2.6
        XCTAssertGreaterThan(newFactor, 2.5)
    }
    
    func testEaseFactorAdjustmentForIncorrect() {
        let newFactor = engine.adjustEaseFactor(2)
        // SM-2: EF = EF + (0.1 - (2 - 3) * 0.08)
        // = 2.5 + 0.1 - (-0.08) = lower
        XCTAssertLess(newFactor, 2.5)
    }
    
    func testEaseFactorMinimumBound() {
        let newFactor = engine.adjustEaseFactor(0)
        XCTAssertGreaterThanOrEqual(newFactor, 1.3)
    }
    
    func testQualityClampedTo0_5() {
        // Quality outside [0, 5] should be clamped
        let interval1 = engine.calculateNextInterval(
            currentInterval: 1,
            easeFactor: 2.5,
            quality: 10  // > 5
        )
        
        let interval2 = engine.calculateNextInterval(
            currentInterval: 1,
            easeFactor: 2.5,
            quality: 5
        )
        
        XCTAssertEqual(interval1, interval2)
    }
}