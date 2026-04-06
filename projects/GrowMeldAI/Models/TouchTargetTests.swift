import XCTest

final class TouchTargetTests: XCTestCase {
    func testAnswerButtonMinimumSize() {
        let button = AnswerOptionButton(
            option: "Test",
            isSelected: false,
            action: {}
        )
        
        // Measure button frame
        let measured = button.preferredContentSize
        XCTAssertGreaterThanOrEqual(measured.height, 44, "Button must be ≥44pt tall")
        XCTAssertGreaterThanOrEqual(measured.width, 44, "Button must be ≥44pt wide")
    }
}