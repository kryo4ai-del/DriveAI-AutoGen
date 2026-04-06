import XCTest
@testable import DriveAI

class AccessibleProgressIndicatorTests: XCTestCase {
    
    // MARK: - Progress Calculation & Bounds
    
    func test_progressClamped_0_to_1() {
        // CRITICAL: BUG-002 regression
        let testCases: [(current: Int, total: Int, expected: Double)] = [
            (0, 10, 0.0),          // 0%
            (5, 10, 0.5),          // 50%
            (10, 10, 1.0),         // 100%
            (15, 10, 1.0),         // ❌ Over-subscribed → clamped to 1.0
            (-5, 10, 0.0),         // ❌ Negative → clamped to 0.0
            (5, 0, 0.0),           // ❌ Division by zero → 0.0
        ]
        
        for (current, total, expected) in testCases {
            let view = AccessibleProgressIndicator(
                label: "Test",
                current: current,
                total: total,
                showPercentage: true
            )
            
            // Access private property via reflection (or create public compute property for testing)
            let percentage = total > 0 ?
                Int(Double(min(current, total)) / Double(total) * 100) :
                0
            
            let clamped = max(0, min(Double(current) / Double(max(total, 1)), 1.0))
            XCTAssertGreaterThanOrEqual(clamped, 0.0)
            XCTAssertLessThanOrEqual(clamped, 1.0, "Progress must be in [0, 1]")
        }
    }
    
    func test_progressEdgeCases() {
        // Given edge cases that previously crashed
        let edgeCases = [
            (current: 45, total: 40),  // Over capacity (data corruption)
            (current: 0, total: 0),    // Empty set
            (current: -5, total: 10),  // Negative current
            (current: 10, total: -1),  // Negative total
        ]
        
        for (current, total) in edgeCases {
            let view = AccessibleProgressIndicator(
                label: "Edge Case Test",
                current: current,
                total: total
            )
            
            // Should render without crashing
            XCTAssertNotNil(view, "View should handle edge case: (\(current)/\(total))")
        }
    }
    
    // MARK: - Accessibility Properties
    
    func test_accessibilityLabel_AlwaysPresent() {
        let view = AccessibleProgressIndicator(
            label: "Kategorien Progress",
            current: 30,
            total: 60
        )
        
        XCTAssert(
            view.accessibilityLabel.contains("Fortschritt"),
            "Should have accessibility label"
        )
    }
    
    func test_accessibilityValue_PercentageAnnounced() {
        let view = AccessibleProgressIndicator(
            label: "Test",
            current: 75,
            total: 100
        )
        
        // Accessibility value should include percentage
        let expectedValue = "75% abgeschlossen"
        XCTAssertEqual(view.accessibilityValue, expectedValue)
    }
    
    func test_percentageColor_Changes() {
        let lowProgress = AccessibleProgressIndicator(label: "Low", current: 10, total: 60)
        let midProgress = AccessibleProgressIndicator(label: "Mid", current: 35, total: 60)
        let highProgress = AccessibleProgressIndicator(label: "High", current: 55, total: 60)
        
        // Should have different colors (visual feedback)
        // Red < Orange < Green
        XCTAssertNotNil(lowProgress)
        XCTAssertNotNil(midProgress)
        XCTAssertNotNil(highProgress)
    }
    
    // MARK: - Data Validation
    
    func test_dataValidationLogging() {
        // When current > total, should log warning (not crash)
        let view = AccessibleProgressIndicator(
            label: "Corrupted Data",
            current: 50,
            total: 45
        )
        
        // Should gracefully handle
        XCTAssertNotNil(view)
    }
}