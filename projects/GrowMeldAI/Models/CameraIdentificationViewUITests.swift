// Tests/KIIdentification/UI/CameraIdentificationViewTests.swift
class CameraIdentificationViewUITests: XCTestCase {
    func test_cameraPermissionDenied_showsEnablePrompt() {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to KI-Identifikation
        app.buttons["Zeichen scannen"].tap()
        
        // Assert: permission prompt visible
        XCTAssert(app.alerts.element.exists)
        XCTAssert(app.staticTexts["Kamera-Zugriff erforderlich"].exists)
    }
}