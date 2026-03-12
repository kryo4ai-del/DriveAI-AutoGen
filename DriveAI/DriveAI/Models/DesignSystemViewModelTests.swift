import XCTest
import Combine
@testable import DriveAI

class DesignSystemViewModelTests: XCTestCase {

    var viewModel: DesignSystemViewModel!
    var themeService: ThemeService!

    override func setUp() {
        super.setUp()
        themeService = ThemeService()
        viewModel = DesignSystemViewModel(themeService: themeService)
    }

    func testInitialThemeIsLight() {
        XCTAssertEqual(viewModel.theme, .light)
    }

    func testToggleThemeChangesValue() {
        viewModel.toggleTheme()
        XCTAssertEqual(viewModel.theme, .dark)

        viewModel.toggleTheme()
        XCTAssertEqual(viewModel.theme, .light)
    }

    func testThemeChangeNotification() {
        let expectation = XCTestExpectation(description: "Notify theme change")
        viewModel.$theme
            .dropFirst().sink { newTheme in
                XCTAssertEqual(newTheme, .dark)
                expectation.fulfill()
            }.store(in: &viewModel.cancellables)
        
        viewModel.toggleTheme() // Triggering theme change
        wait(for: [expectation], timeout: 1.0)
    }
}