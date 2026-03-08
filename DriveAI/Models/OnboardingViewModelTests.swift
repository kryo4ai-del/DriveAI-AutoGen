import XCTest
import Combine
@testable import DriveAI

class OnboardingViewModelTests: XCTestCase {
    var viewModel: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        viewModel = OnboardingViewModel()
    }

    func testInitialState() {
        // Check the initial state of the ViewModel
        XCTAssertEqual(viewModel.currentPage, 0)
        XCTAssertEqual(viewModel.totalPages, 3) // Assuming there are 3 screens defined
    }

    func testNextPageFunctionality() {
        viewModel.nextPage()
        // After next page call, currentPage should increment
        XCTAssertEqual(viewModel.currentPage, 1)

        // Test that the currentPage does not exceed the last page index
        viewModel.currentPage = 2
        viewModel.nextPage()
        XCTAssertEqual(viewModel.currentPage, 2) // Should still be the last page
    }

    func testSkipOnboarding() {
        viewModel.skipOnboarding()
        // Should set currentPage to the last index
        XCTAssertEqual(viewModel.currentPage, 2)
    }

    func testScreenRetrieval() {
        let screen = viewModel.screen(for: 1)
        // Check that retrieving the second screen returns the correct data
        XCTAssertEqual(screen.title, "Track Your Progress")
        XCTAssertEqual(screen.description, "Monitor your preparation for the driver's license exam.")
    }
}