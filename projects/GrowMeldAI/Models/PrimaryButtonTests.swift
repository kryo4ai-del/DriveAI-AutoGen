// ComponentTests/PrimaryButtonTests.swift
final class PrimaryButtonTests: XCTestCase {
    func testButtonAppearanceLight() {
        let button = PrimaryButton("Submit") { }
        assertSnapshot(matching: button, as: .image)
    }
    
    func testButtonAccessibility() {
        let button = PrimaryButton("Submit") { }
        XCTAssert(button.accessibilityLabel != nil)
        XCTAssert(button.accessibilityHint != nil)
    }
}