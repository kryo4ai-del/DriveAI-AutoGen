import XCTest
@testable import DriveAI

class OnboardingScreenModelTests: XCTestCase {

    func testOnboardingScreenModelInitialization() {
        // Initialize the model
        let model = OnboardingScreenModel(title: "Sample Title", description: "Sample Description", imageName: "sample_image")
        
        // Verify initial values
        XCTAssertEqual(model.title, "Sample Title")
        XCTAssertEqual(model.description, "Sample Description")
        XCTAssertEqual(model.imageName, "sample_image")
    }

    func testFormattedTitle() {
        // Create a model instance
        let model = OnboardingScreenModel(title: "Sample Title", description: "", imageName: "")
        
        // Verify formatted title output
        XCTAssertEqual(model.formattedTitle, "SAMPLE TITLE") // Ensure formatting is as expected
    }
}