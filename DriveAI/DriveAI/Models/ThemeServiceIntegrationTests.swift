import XCTest
@testable import DriveAI

class ThemeServiceIntegrationTests: XCTestCase {

    var themeService: ThemeService!

    override func setUp() {
        super.setUp()
        themeService = ThemeService()
    }

    func testThemeUpdatesCorrectly() {
        themeService.updateTheme(.dark)
        XCTAssertEqual(themeService.currentTheme, .dark, "Theme should update to dark when set.");

        themeService.updateTheme(.light)
        XCTAssertEqual(themeService.currentTheme, .light, "Theme should update to light when set.");
    }

    func testGettingThemeColors() {
        themeService.updateTheme(.dark)
        let colors = themeService.getColors()
        XCTAssertEqual(colors.primary, Color.yellow, "Primary color should match dark theme color.");
        XCTAssertEqual(colors.background, Color.black, "Background color should match dark theme color.");
    }
}