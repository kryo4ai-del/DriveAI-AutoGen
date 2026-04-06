// Tests/Views/Components/AccessibleMultipleChoiceOptionTests.swift
class AccessibleMultipleChoiceOptionTests: XCTestCase {
    func testAccessibilityLabel() {
        let view = AccessibleMultipleChoiceOption(
            optionNumber: 1,
            totalOptions: 4,
            text: "Test answer",
            isSelected: false,
            feedbackState: nil,
            action: {}
        )
        
        let label = view.accessibilityLabel
        XCTAssert(label.contains("Antwort 1 von 4"))
    }
    
    func testColorContrast() {
        // Verify all hardcoded colors meet 4.5:1 minimum
        let correctColor = AnswerFeedbackState.correct.color
        let contrastRatio = calculateContrast(correctColor, Color.white)
        XCTAssertGreaterThanOrEqual(contrastRatio, 4.5)
    }
}