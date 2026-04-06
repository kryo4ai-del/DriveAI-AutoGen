final class OnboardingUITests: XCTestCase {
    func testCompleteOnboardingFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Welcome → DatePicker
        XCUIApplication().buttons["Jetzt starten"].tap()
        XCTAssertTrue(app.staticTexts["Wann ist dein Prüfungstermin?"].exists)
        
        // DatePicker → Categories
        app.buttons["Weiter"].tap()
        XCTAssertTrue(app.staticTexts["Welche Kategorien interessieren dich?"].exists)
        
        // Categories → Completion
        app.buttons["Verkehrszeichen"].tap()
        app.buttons["Weiter"].tap()
        XCTAssertTrue(app.staticTexts["Willkommen!"].exists)
    }
}