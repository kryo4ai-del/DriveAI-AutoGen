// MARK: - Tests/Domain/Models/MasteryLevelTests.swift

import XCTest
@testable import DriveAI

final class MasteryLevelTests: XCTestCase {
    
    // MARK: - fromAccuracy Tests
    
    func test_fromAccuracy_belowForty_returnsNovice() {
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.0), .novice)
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.39), .novice)
    }
    
    func test_fromAccuracy_fortyToSixtyNine_returnsIntermediate() {
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.40), .intermediate)
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.65), .intermediate)
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.69), .intermediate)
    }
    
    func test_fromAccuracy_seventyToEightyNine_returnsProficient() {
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.70), .proficient)
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.85), .proficient)
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.89), .proficient)
    }
    
    func test_fromAccuracy_ninetyAndAbove_returnsExpert() {
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.90), .expert)
        XCTAssertEqual(MasteryLevel.fromAccuracy(0.99), .expert)
        XCTAssertEqual(MasteryLevel.fromAccuracy(1.0), .expert)
    }
    
    // MARK: - Comparable Tests
    
    func test_comparison_noviceLessThanIntermediate() {
        XCTAssertLessThan(MasteryLevel.novice, .intermediate)
    }
    
    func test_comparison_intermediateLessThanProficient() {
        XCTAssertLessThan(MasteryLevel.intermediate, .proficient)
    }
    
    func test_comparison_proficientLessThanExpert() {
        XCTAssertLessThan(MasteryLevel.proficient, .expert)
    }
    
    func test_comparison_sortsByRawValue() {
        let levels: [MasteryLevel] = [.expert, .novice, .proficient, .intermediate]
        let sorted = levels.sorted()
        XCTAssertEqual(sorted, [.novice, .intermediate, .proficient, .expert])
    }
    
    // MARK: - Properties Tests
    
    func test_novice_hasRedColor() {
        XCTAssertEqual(MasteryLevel.novice.color, .red)
    }
    
    func test_expert_hasGreenColor() {
        XCTAssertEqual(MasteryLevel.expert.color, .green)
    }
    
    func test_allLevels_haveLabels() {
        XCTAssertFalse(MasteryLevel.novice.label.isEmpty)
        XCTAssertFalse(MasteryLevel.intermediate.label.isEmpty)
        XCTAssertFalse(MasteryLevel.proficient.label.isEmpty)
        XCTAssertFalse(MasteryLevel.expert.label.isEmpty)
    }
}