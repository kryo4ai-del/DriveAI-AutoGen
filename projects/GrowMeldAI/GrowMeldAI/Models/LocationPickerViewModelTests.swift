// Tests/Features/LocationPickerTests/LocationPickerViewModelTests.swift

import XCTest
@testable import DriveAI

@MainActor
final class LocationPickerViewModelTests: XCTestCase {
    var viewModel: LocationPickerViewModel!
    var mockDataService: MockLocationDataService!
    var appState: AppState!
    
    override func setUp() async throws {
        mockDataService = MockLocationDataService()
        appState = AppState(locationDataService: mockDataService)
        viewModel = LocationPickerViewModel(
            locationDataService: mockDataService,
            appState: appState
        )
    }
    
    func testSearchDebounceDelay() async throws {
        // Rapid text input
        viewModel.updateSearchQuery("b")
        viewModel.updateSearchQuery("be")
        
        // Debounce should not trigger yet
        try await Task.sleep(nanoseconds: 200_000_000)  // 200ms
        XCTAssert(viewModel.state.suggestedRegions.isEmpty)
        
        // Wait for debounce window
        try await Task.sleep(nanoseconds: 150_000_000)  // Total 350ms
        XCTAssertFalse(viewModel.state.suggestedRegions.isEmpty)
    }
    
    func testLocationSelection() async throws {
        let region = Region(id: "10115", plz: "10115", city: "Berlin", state: "Berlin", questionCount: 500)
        
        await viewModel.selectLocation(region)
        
        XCTAssertEqual(appState.selectedLocation?.id, "10115")
    }
    
    func testEmptyQueryClearsResults() {
        viewModel.updateSearchQuery("berlin")
        XCTAssertFalse(viewModel.state.suggestedRegions.isEmpty)
        
        viewModel.updateSearchQuery("")
        XCTAssert(viewModel.state.suggestedRegions.isEmpty)
    }
}