// Tests/Unit/Models/FocusLevelTests.swift
import XCTest
@testable import DriveAI

final class FocusLevelTests: XCTestCase {
    
    // MARK: - Urgency Level Tests
    
    func testUrgencyLevelOrdering() {
        XCTAssertEqual(FocusLevel.green.urgencyLevel, 0)
        XCTAssertEqual(FocusLevel.yellow.urgencyLevel, 1)
        XCTAssertEqual(FocusLevel.orange.urgencyLevel, 2)
        XCTAssertEqual(FocusLevel.red.urgencyLevel, 3)
    }
    
    func testComparableProtocolOrdering() {
        let levels: [FocusLevel] = [.green, .red, .yellow, .orange]
        let sorted = levels.sorted()
        
        XCTAssertEqual(sorted, [.green, .yellow, .orange, .red])
    }
    
    func testComparisonOperators() {
        XCTAssertTrue(FocusLevel.red > FocusLevel.yellow)
        XCTAssertTrue(FocusLevel.yellow < FocusLevel.red)
        XCTAssertTrue(FocusLevel.green < FocusLevel.orange)
        XCTAssertFalse(FocusLevel.green > FocusLevel.green)
    }
    
    // MARK: - Localization Tests
    
    func testLabelsNotEmpty() {
        for level in FocusLevel.allCases {
            XCTAssertFalse(level.label.isEmpty, "Label should not be empty for \(level)")
            XCTAssertFalse(level.description.isEmpty, "Description should not be empty for \(level)")
        }
    }
    
    func testGermanLabelsPresent() {
        XCTAssertEqual(FocusLevel.red.label, "Kritisch")
        XCTAssertEqual(FocusLevel.orange.label, "Wichtiger Fokus")
        XCTAssertEqual(FocusLevel.yellow.label, "Bald wiederholen")
        XCTAssertEqual(FocusLevel.green.label, "Sicher beherrscht")
    }
    
    // MARK: - Edge Cases
    
    func testUrgencyLevelIndependentOfOrdering() {
        // Verify urgency is explicit, not dependent on enum case order
        XCTAssertEqual(FocusLevel.red.urgencyLevel, 3)
        XCTAssertEqual(FocusLevel.green.urgencyLevel, 0)
        
        // Reordering enum cases should not change urgency logic
        // This test documents the behavior we're protecting against
    }
}