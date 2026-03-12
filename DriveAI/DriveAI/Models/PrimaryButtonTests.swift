import XCTest
import SwiftUI
@testable import DriveAI

class PrimaryButtonTests: XCTestCase {

    var primaryButton: PrimaryButton!

    override func setUp() {
        super.setUp()
        primaryButton = PrimaryButton(title: "Test Button", action: {})
    }

    func testButtonText() {
        let buttonBody = primaryButton.body
        let buttonDescription = buttonBody.debugDescription
        XCTAssertTrue(buttonDescription.contains("Test Button"), "Button text should match the expected title.")
    }

    func testAccessibilityLabel() {
        let buttonBody = primaryButton.body
        XCTAssertEqual(buttonBody.accessibilityLabel, "Primary button: Test Button", "Accessibility label should match expected format.")
    }
}