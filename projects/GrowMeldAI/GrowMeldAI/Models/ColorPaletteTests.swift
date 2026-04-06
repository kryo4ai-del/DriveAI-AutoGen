// ColorPaletteTests.swift
final class ColorPaletteTests: XCTestCase {
    func testDarkModeReactivity() {
        let light = ColorPalette.forScheme(.light)
        let dark = ColorPalette.forScheme(.dark)
        
        // Verify distinctly different
        XCTAssertNotEqual(light.background, dark.background)
        XCTAssertNotEqual(light.text, dark.text)
    }
}