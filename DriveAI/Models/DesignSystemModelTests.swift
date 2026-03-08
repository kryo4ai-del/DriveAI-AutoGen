import XCTest
import SwiftUI
@testable import DriveAI

class DesignSystemModelTests: XCTestCase {

    var designSystemModel: DesignSystemModel!

    override func setUp() {
        super.setUp()
        designSystemModel = DesignSystemModel()
    }

    func testThemeColorsForLight() {
        let colors = designSystemModel.colors(for: .light)
        XCTAssertEqual(colors.primary, Color.blue)
        XCTAssertEqual(colors.background, Color.white)
    }

    func testThemeColorsForDark() {
        let colors = designSystemModel.colors(for: .dark)
        XCTAssertEqual(colors.primary, Color.yellow)
        XCTAssertEqual(colors.background, Color.black)
    }

    func testFontForLightTheme() {
        let font = designSystemModel.font(for: .light, size: 16)
        XCTAssertEqual(font, Font.system(size: 16, weight: .regular, design: .default))
    }

    func testFontForDarkTheme() {
        let font = designSystemModel.font(for: .dark, size: 16)
        XCTAssertEqual(font, Font.system(size: 16, weight: .bold, design: .default))
    }
}