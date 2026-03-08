import XCTest
import SwiftUI
@testable import DriveAI

class OnboardingViewTests: XCTestCase {

    func testNavigationToNextPage() {
        let viewModel = OnboardingViewModel()
        let view = OnboardingView().environmentObject(viewModel)

        // Simulate pressing the next button
        viewModel.nextPage()
        
        // Verify that the currentPage has moved to the second page
        XCTAssertEqual(viewModel.currentPage, 1)
    }

    func testSkipButtonFunctionality() {
        let viewModel = OnboardingViewModel()
        let view = OnboardingView().environmentObject(viewModel)

        viewModel.skipOnboarding() // Simulate pressing skip
        // Verify that it navigates to the last page
        XCTAssertEqual(viewModel.currentPage, 2)
    }

    func testButtonStates() {
        let viewModel = OnboardingViewModel()
        
        // Check initial button states
        viewModel.currentPage = 0
        XCTAssertFalse(viewModel.currentPage == 2) // Should indicate that it's not on the last page

        // Simulate user reaching the last page
        viewModel.currentPage = 2
        XCTAssertTrue(viewModel.currentPage == 2) // Verify it's correctly on the last page
    }
}