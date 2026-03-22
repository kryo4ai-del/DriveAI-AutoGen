class QuickAccessUITests: XCUITestCase {
    func test_quickAccessButton_tappedTriggersNavigation() {
        // Arrange
        let app = XCUIApplication()
        app.launch()
        
        // Act
        app.buttons["Quick Review"].tap()
        
        // Assert
        XCTAssertTrue(app.staticTexts["Quiz"].exists)
    }
}