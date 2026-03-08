import XCTest
@testable import DriveAI

class EdgeCaseTests: XCTestCase {
    
    func testEmptyScreensInViewModel() {
        let viewModel = OnboardingViewModel()
        // Ensure the ViewModel can handle its state correctly
        XCTAssertEqual(viewModel.totalPages, 3) // Assuming the screens are initialized
        XCTAssertEqual(viewModel.currentPage, 0) // Should not crash or misbehave
    }

    func testOutOfBoundsIndexRetrieval() {
        let viewModel = OnboardingViewModel()
        
        // Attempt to access a screen with an out-of-bounds index
        let screen = viewModel.screen(for: 3) // Invalid index; should be handled gracefully
        XCTAssertNil(screen) // Ensure it does not crash and can handle the request
    }
}