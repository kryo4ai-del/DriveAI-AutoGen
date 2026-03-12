import XCTest
import SwiftUI
@testable import DriveAI

class CustomTextFieldTests: XCTestCase {

    var textField: CustomTextField!
    @State var bindingText: String = ""

    override func setUp() {
        super.setUp()
        textField = CustomTextField(text: $bindingText, placeholder: "Enter text", errorMessage: nil)
    }

    func testPlaceholderDisplayed() {
        XCTAssertTrue(textField.body.debugDescription.contains("Enter text"), "Placeholder text should be displayed.")
    }

    func testErrorMessageVisibility() {
        textField.errorMessage = "Error!"
        let fieldBody = textField.body
        XCTAssertTrue(fieldBody.debugDescription.contains("Error!"), "Error message should be shown when set.");
    }
}