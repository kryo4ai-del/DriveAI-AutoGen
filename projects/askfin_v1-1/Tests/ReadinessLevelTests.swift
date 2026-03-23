import XCTest
@testable import DriveAI

final class ReadinessLevelTests: XCTestCase {
    
    func test_init_fromScore_notReady() {
        let level = ReadinessLevel(score: 49.0)
        XCTAssertEqual(level, .notReady)
    }
    
    func test_init_fromScore_developing() {
        let level = ReadinessLevel(score: 60.0)
        XCTAssertEqual(level, .developing)
    }
    
    func test_init_fromScore_prepared() {
        let level = ReadinessLevel(score: 75.0)
        XCTAssertEqual(level, .prepared)
    }
    
    func test_init_fromScore_wellPrepared() {
        let level = ReadinessLevel(score: 85.0)
        XCTAssertEqual(level, .wellPrepared)
    }
    
    func test_init_fromScore_boundaries() {
        XCTAssertEqual(ReadinessLevel(score: 0.0), .notReady)
        XCTAssertEqual(ReadinessLevel(score: 50.0), .developing)
        XCTAssertEqual(ReadinessLevel(score: 70.0), .prepared)
        XCTAssertEqual(ReadinessLevel(score: 85.0), .wellPrepared)
    }
    
    func test_comparison_ordering() {
        XCTAssertLessThan(.notReady, .developing)
        XCTAssertLessThan(.developing, .prepared)
        XCTAssertLessThan(.prepared, .wellPrepared)
    }
    
    func test_displayName_returnsLocalizedString() {
        XCTAssertEqual(ReadinessLevel.notReady.displayName, "Not Ready")
        XCTAssertEqual(ReadinessLevel.developing.displayName, "Developing")
        XCTAssertEqual(ReadinessLevel.prepared.displayName, "Prepared")
        XCTAssertEqual(ReadinessLevel.wellPrepared.displayName, "Well Prepared")
    }
    
    func test_emoji_returnsAppropriateEmoji() {
        XCTAssertEqual(ReadinessLevel.notReady.emoji, "🔴")
        XCTAssertEqual(ReadinessLevel.developing.emoji, "🟠")
        XCTAssertEqual(ReadinessLevel.prepared.emoji, "🟡")
        XCTAssertEqual(ReadinessLevel.wellPrepared.emoji, "🟢")
    }
}