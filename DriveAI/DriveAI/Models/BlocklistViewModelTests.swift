import XCTest
import Combine
@testable import DriveAI

class BlocklistViewModelTests: XCTestCase {
    var viewModel: BlocklistViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = BlocklistViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadBlocklistSuccess() {
        let expectation = XCTestExpectation(description: "Load blocklist items")
        
        viewModel.$blocklistItems
            .dropFirst() // Ignore initial empty state
            .sink { items in
                XCTAssertFalse(items.isEmpty, "Blocklist items should not be empty")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.loadBlocklist() // Simulate loading
        
        wait(for: [expectation], timeout: 3.0) // Wait for the async loading to complete
    }
    
    func testLoadBlocklistErrorHandling() {
        let expectation = XCTestExpectation(description: "Handling error message")
        
        // Simulate error scenario directly in the view model for this test
        viewModel.$errorMessage
            .dropFirst() // Ignore initial nil state
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "Fehler beim Laden der Blockliste", "Error message should be set correctly")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Introduce a method to simulate an error in loadBlocklist
        viewModel.simulateLoadingError() // This method will be created in the ViewModel
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testBlocklistItemsEmptyInitially() {
        XCTAssertTrue(viewModel.blocklistItems.isEmpty, "Initially, blocklist items should be empty")
    }

    func testLoadingStateInitiallyFalse() {
        XCTAssertFalse(viewModel.isLoading, "Initially, loading state should be false")
    }
    
    func testLoadingStateChangesDuringLoad() {
        viewModel.loadBlocklist() // Start loading
        XCTAssertTrue(viewModel.isLoading, "Loading state should be true when loading begins")
        
        // Allow time for the asynchronous call to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading state should be false after loading completes")
        }
    }
}