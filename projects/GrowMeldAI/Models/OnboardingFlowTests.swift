// Tests/UI/OnboardingFlowTests.swift
class OnboardingFlowTests: XCTestCase {
    func testCompleteOnboarding() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap welcome button
        app.buttons["Start Learning"].tap()
        
        // Toggle consent
        app.switches["analyticsConsent"].tap()
        
        // Set exam date
        app.datePickers.firstMatch.adjust(toPickerWheelValue: "2026")
        
        // Verify home screen
        XCTAssertTrue(app.staticTexts["Welcome Home"].exists)
    }
}