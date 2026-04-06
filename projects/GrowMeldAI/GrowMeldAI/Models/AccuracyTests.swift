// MARK: - Tests/Domain/Unit/ValueObjects/AccuracyTests.swift

import XCTest
@testable import DriveAI

final class AccuracyTests: XCTestCase {
    
    // MARK: - Initialization & Validation
    
    func testInitWithValidPercentage() {
        let accuracy = Accuracy(75.5)
        XCTAssertNotNil(accuracy)
        XCTAssertEqual(accuracy?.value, 75.5)
    }
    
    func testInitRejectsNegativePercentage() {
        let accuracy = Accuracy(-10)
        XCTAssertNil(accuracy)
    }
    
    func testInitRejectsPercentageAbove100() {
        let accuracy = Accuracy(101)
        XCTAssertNil(accuracy)
    }
    
    func testInitAccepts0Percent() {
        let accuracy = Accuracy(0)
        XCTAssertNotNil(accuracy)
        XCTAssertEqual(accuracy?.value, 0)
    }
    
    func testInitAccepts100Percent() {
        let accuracy = Accuracy(100)
        XCTAssertNotNil(accuracy)
        XCTAssertEqual(accuracy?.value, 100)
    }
    
    // MARK: - Initialize from Quiz Results
    
    func testInitFromQuizResults_AllCorrect() {
        let accuracy = Accuracy(5, 5)
        XCTAssertNotNil(accuracy)
        XCTAssertEqual(accuracy?.value, 100)
    }
    
    func testInitFromQuizResults_PartialCorrect() {
        let accuracy = Accuracy(2, 3)
        XCTAssertNotNil(accuracy)
        XCTAssertEqual(accuracy?.displayText, "67%")
    }
    
    func testInitFromQuizResults_AllIncorrect() {
        let accuracy = Accuracy(0, 5)
        XCTAssertNotNil(accuracy)
        XCTAssertEqual(accuracy?.value, 0)
    }
    
    func testInitFromQuizResults_ZeroTotal() {
        let accuracy = Accuracy(0, 0)
        XCTAssertNil(accuracy)
    }
    
    func testInitFromQuizResults_NegativeCorrect() {
        let accuracy = Accuracy(-1, 5)
        XCTAssertNil(accuracy)
    }
    
    func testInitFromQuizResults_CorrectExceedsTotal() {
        let accuracy = Accuracy(10, 5)
        XCTAssertNil(accuracy)
    }
    
    // MARK: - Comparison (with Epsilon Tolerance)
    
    func testEqualityWithinEpsilon() {
        // 66.666... should equal 66.67 (within 0.01% tolerance)
        let a1 = Accuracy(2, 3)!
        let a2 = Accuracy(66.67)!
        XCTAssertEqual(a1, a2)
    }
    
    func testEqualityExactMatch() {
        let a1 = Accuracy(75)!
        let a2 = Accuracy(75)!
        XCTAssertEqual(a1, a2)
    }
    
    func testInequalityOutsideEpsilon() {
        let a1 = Accuracy(75)!
        let a2 = Accuracy(75.02)!  // Beyond 0.01% tolerance
        XCTAssertNotEqual(a1, a2)
    }
    
    func testLessThanComparison() {
        let low = Accuracy(40)!
        let high = Accuracy(80)!
        XCTAssert(low < high)
        XCTAssertFalse(high < low)
    }
    
    func testLessThanWithinEpsilon() {
        let a1 = Accuracy(74.99)!
        let a2 = Accuracy(75)!
        XCTAssertFalse(a1 < a2)  // Too close; considered equal
    }
    
    func testGreaterThanOrEqualComparison() {
        let a1 = Accuracy(75)!
        let a2 = Accuracy(75)!
        let a3 = Accuracy(74)!
        XCTAssert(a1 >= a2)
        XCTAssert(a1 >= a3)
    }
    
    // MARK: - Hashable (must match Equatable)
    
    func testHashConsistency() {
        let a1 = Accuracy(2, 3)!
        let a2 = Accuracy(66.67)!
        
        // Equal values must have same hash
        XCTAssertEqual(a1, a2)
        XCTAssertEqual(a1.hashValue, a2.hashValue)
    }
    
    func testHashableInSet() {
        let a1 = Accuracy(75)!
        let a2 = Accuracy(75.005)!  // Within epsilon, equal
        let a3 = Accuracy(80)!
        
        let set: Set<Accuracy> = [a1, a2, a3]
        XCTAssertEqual(set.count, 2)  // a1 and a2 are identical
    }
    
    // MARK: - Display & Proficiency
    
    func testDisplayText() {
        XCTAssertEqual(Accuracy(75.0)?.displayText, "75%")
        XCTAssertEqual(Accuracy(66.67)?.displayText, "67%")
        XCTAssertEqual(Accuracy(100)?.displayText, "100%")
    }
    
    func testProficiencyLevel_Weak() {
        let acc = Accuracy(35)!
        XCTAssertEqual(acc.proficiencyLevel, .weak)
    }
    
    func testProficiencyLevel_Fair() {
        let acc = Accuracy(55)!
        XCTAssertEqual(acc.proficiencyLevel, .fair)
    }
    
    func testProficiencyLevel_Strong() {
        let acc = Accuracy(85)!
        XCTAssertEqual(acc.proficiencyLevel, .strong)
    }
    
    func testMilestoneThreshold() {
        let below = Accuracy(74.99)!
        let at = Accuracy(75)!
        let above = Accuracy(75.01)!
        
        XCTAssertFalse(below.hasReachedMilestone)
        XCTAssert(at.hasReachedMilestone)
        XCTAssert(above.hasReachedMilestone)
    }
    
    // MARK: - Difficulty Recommendation
    
    func testSuggestedDifficulty_Easy() {
        let acc = Accuracy(35)!
        XCTAssertEqual(acc.suggestedDifficulty, .easy)
    }
    
    func testSuggestedDifficulty_Medium() {
        let acc = Accuracy(55)!
        XCTAssertEqual(acc.suggestedDifficulty, .medium)
    }
    
    func testSuggestedDifficulty_Hard() {
        let acc = Accuracy(85)!
        XCTAssertEqual(acc.suggestedDifficulty, .hard)
    }
    
    // MARK: - Codable
    
    func testCodable() throws {
        let accuracy = Accuracy(75.5)!
        
        let data = try JSONEncoder().encode(accuracy)
        let decoded = try JSONDecoder().decode(Accuracy.self, from: data)
        
        XCTAssertEqual(accuracy, decoded)
    }
}