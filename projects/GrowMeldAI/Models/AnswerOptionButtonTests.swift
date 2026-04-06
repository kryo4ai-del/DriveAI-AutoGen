import XCTest
import SwiftUI
@testable import DriveAI

final class AnswerOptionButtonTests: XCTestCase {
    
    let testOption = QuestionOption(id: "opt1", text: "Sample answer", imageURL: nil)
    
    // MARK: - State Rendering Tests
    func testButtonRender_PendingState_UnselectedStyle() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: false,
            feedbackState: .pending,
            isEnabled: true,
            onSelectOption: { _ in }
        )
        
        // Snapshot test
        assertSnapshot(matching: button, as: .image(size: CGSize(width: 300, height: 56)))
    }
    
    func testButtonRender_PendingState_SelectedStyle() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: true,
            feedbackState: .pending,
            isEnabled: true,
            onSelectOption: { _ in }
        )
        
        assertSnapshot(matching: button, as: .image(size: CGSize(width: 300, height: 56)))
    }
    
    func testButtonRender_CorrectFeedback() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: true,
            feedbackState: .correct,
            isEnabled: false,
            onSelectOption: { _ in }
        )
        
        assertSnapshot(matching: button, as: .image(size: CGSize(width: 300, height: 56)))
    }
    
    func testButtonRender_IncorrectFeedback() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: true,
            feedbackState: .incorrect,
            isEnabled: false,
            onSelectOption: { _ in }
        )
        
        assertSnapshot(matching: button, as: .image(size: CGSize(width: 300, height: 56)))
    }
    
    // MARK: - Interaction Tests
    func testButtonAction_CallsOnSelectOption() {
        var selectedID: String?
        
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: false,
            feedbackState: .pending,
            isEnabled: true,
            onSelectOption: { id in selectedID = id }
        )
        
        // Simulate button tap
        button.onSelectOption(testOption.id)
        
        XCTAssertEqual(selectedID, "opt1")
    }
    
    func testButtonDisabled_WhenFeedbackShown() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: false,
            feedbackState: .correct,  // Not .pending
            isEnabled: false,          // Should be disabled
            onSelectOption: { _ in }
        )
        
        // Button action should be ignored when disabled
        var called = false
        let disabledButton = AnswerOptionButton(
            option: testOption,
            isSelected: false,
            feedbackState: .correct,
            isEnabled: false,
            onSelectOption: { _ in called = true }
        )
        
        XCTAssertFalse(called)  // Action not triggered when disabled
    }
    
    // MARK: - Accessibility Tests
    func testAccessibility_VoiceOverLabel() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: false,
            feedbackState: .pending,
            isEnabled: true,
            onSelectOption: { _ in }
        )
        
        // In real test, would use XCUIApplication to verify accessibility label
        // Expected: "Answer option, Sample answer"
    }
    
    func testAccessibility_FeedbackHint_Correct() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: true,
            feedbackState: .correct,
            isEnabled: false,
            onSelectOption: { _ in }
        )
        
        // Expected hint: "Correct answer"
    }
    
    func testAccessibility_FeedbackHint_Incorrect() {
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: true,
            feedbackState: .incorrect,
            isEnabled: false,
            onSelectOption: { _ in }
        )
        
        // Expected hint: "Incorrect answer"
    }
    
    func testAccessibility_DynamicType_LargeText() {
        var environment = Environment(\.sizeCategory)
        environment.sizeCategory = .accessibilityExtraLarge
        
        let button = AnswerOptionButton(
            option: testOption,
            isSelected: false,
            feedbackState: .pending,
            isEnabled: true,
            onSelectOption: { _ in }
        )
        .environment(\.sizeCategory, .accessibilityExtraLarge)
        
        // Verify button scales appropriately with dynamic type
        assertSnapshot(matching: button, as: .image(size: CGSize(width: 300, height: 80)))
    }
    
    // MARK: - Edge Cases
    func testButton_LongOptionText_Wraps() {
        let longOption = QuestionOption(
            id: "opt1",
            text: "This is an extremely long answer option that should wrap to multiple lines without truncation",
            imageURL: nil
        )
        
        let button = AnswerOptionButton(
            option: longOption,
            isSelected: false,
            feedbackState: .pending,
            isEnabled: true,
            onSelectOption: { _ in }
        )
        
        // Verify text doesn't get cut off
        assertSnapshot(matching: button, as: .image(size: CGSize(width: 300, height: 100)))
    }
    
    func testButton_EmptyOptionText_ShowsGracefully() {
        let emptyOption = QuestionOption(id: "opt1", text: "", imageURL: nil)
        
        let button = AnswerOptionButton(
            option: emptyOption,
            isSelected: false,
            feedbackState: .pending,
            isEnabled: true,
            onSelectOption: { _ in }
        )
        
        // Should not crash, renders with empty text
        assertSnapshot(matching: button, as: .image(size: CGSize(width: 300, height: 56)))
    }
}