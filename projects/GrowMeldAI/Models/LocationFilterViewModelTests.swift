// Tests/ViewModels/LocationFilterViewModelTests.swift
import XCTest
@testable import DriveAI

@MainActor
final class LocationFilterViewModelTests: XCTestCase {
    var sut: LocationFilterViewModel!
    var mockLocationService: MockLocationService!
    var mockDataService: MockDataService!
    
    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockDataService = MockDataService()
        sut = LocationFilterViewModel(
            locationService: mockLocationService,
            dataService: mockDataService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockLocationService = nil
        mockDataService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization
    
    func test_init_loadsRegionsFromDataService() {
        // Given
        let mockRegions = [
            PLZRegion(id: "BY", name: "Bayern", plzRanges: ["80000-99999"]),
            PLZRegion(id: "BW", name: "Baden-Württemberg", plzRanges: ["70000-79999"])
        ]
        mockDataService.regionsToReturn = mockRegions
        
        // When
        let viewModel = LocationFilterViewModel(
            locationService: mockLocationService,
            dataService: mockDataService
        )
        
        // Then
        XCTAssertEqual(viewModel.allRegions.count, 2)
        XCTAssertEqual(viewModel.allRegions[0].name, "Baden-Württemberg")  // Sorted
        XCTAssertEqual(viewModel.allRegions[1].name, "Bayern")
        XCTAssertNil(viewModel.error)
    }
    
    func test_init_separatesFavoritesFromAllRegions() {
        // Given
        let mockRegions = [
            PLZRegion(id: "BY", name: "Bayern", plzRanges: ["80000-99999"], isFavorite: true),
            PLZRegion(id: "BW", name: "Baden-Württemberg", plzRanges: ["70000-79999"], isFavorite: false),
            PLZRegion(id: "HE", name: "Hessen", plzRanges: ["60000-69999"], isFavorite: true)
        ]
        mockDataService.regionsToReturn = mockRegions
        
        // When
        let viewModel = LocationFilterViewModel(
            locationService: mockLocationService,
            dataService: mockDataService
        )
        
        // Then
        XCTAssertEqual(viewModel.favoriteRegions.count, 2)
        XCTAssertEqual(Set(viewModel.favoriteRegions.map(\.id)), ["BY", "HE"])
    }
    
    func test_init_handlesEmptyRegionsList() {
        // Given
        mockDataService.regionsToReturn = []
        
        // When
        let viewModel = LocationFilterViewModel(
            locationService: mockLocationService,
            dataService: mockDataService
        )
        
        // Then
        XCTAssertTrue(viewModel.allRegions.isEmpty)
        XCTAssertTrue(viewModel.favoriteRegions.isEmpty)
        XCTAssertNil(viewModel.error)
    }
    
    func test_init_handlesDataServiceError() {
        // Given
        mockDataService.shouldThrowError = true
        mockDataService.errorToThrow = .databaseError
        
        // When
        let viewModel = LocationFilterViewModel(
            locationService: mockLocationService,
            dataService: mockDataService
        )
        
        // Then
        XCTAssertTrue(viewModel.allRegions.isEmpty)
        XCTAssertEqual(viewModel.error, .regionLoadFailed)
    }
    
    // MARK: - Location Request
    
    func test_requestLocation_successfullyFetchesRegion() async {
        // Given
        let expectedRegion = PLZRegion(id: "BY", name: "Bayern", plzRanges: ["80000-99999"])
        mockLocationService.regionToReturn = expectedRegion
        
        // When
        sut.requestLocation()
        
        // Then (wait for async completion)
        try? await Task.sleep(nanoseconds: 500_000_000)  // 500ms
        
        XCTAssertEqual(sut.selectedRegion?.id, "BY")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func test_requestLocation_setsLoadingState() async {
        // Given
        mockLocationService.regionToReturn = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        
        // When
        sut.requestLocation()
        
        // Then (immediately after call)
        XCTAssertTrue(sut.isLoading)
        
        // Then (after completion)
        try? await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_requestLocation_handlesLocationServiceError() async {
        // Given
        mockLocationService.shouldThrowError = true
        mockLocationService.errorToThrow = .locationUnavailable
        
        // When
        sut.requestLocation()
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertNil(sut.selectedRegion)
        XCTAssertEqual(sut.error, .locationUnavailable)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_requestLocation_cancellationWorks() async {
        // Given
        let delayedRegion = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        mockLocationService.regionToReturn = delayedRegion
        mockLocationService.shouldDelay = true
        
        // When
        sut.requestLocation()
        
        // Cancel immediately
        try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
        sut.deinit()  // Triggers cancellation in deinit
        
        // Then
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertNil(sut.selectedRegion)  // Should still be nil
    }
    
    func test_requestLocation_replacesInFlightRequest() async {
        // Given
        let region1 = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        let region2 = PLZRegion(id: "BW", name: "Baden-Württemberg", plzRanges: [])
        
        // When
        sut.requestLocation()  // First request
        try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
        
        mockLocationService.regionToReturn = region2
        sut.requestLocation()  // Second request cancels first
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(sut.selectedRegion?.id, "BW")  // Final region is region2
    }
    
    // MARK: - Question Answered (Incremental Progress)
    
    func test_questionAnswered_updatesLocalProgressImmediately() {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        sut.selectedRegion = region
        
        // When
        sut.questionAnswered(inRegion: region, correct: true)
        
        // Then (immediate, no await)
        let progress = sut.regionalProgress[region.id]
        XCTAssertEqual(progress?.answeredCount, 1)
        XCTAssertEqual(progress?.correctCount, 1)
    }
    
    func test_questionAnswered_incrementsCounts() {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        
        // When
        sut.questionAnswered(inRegion: region, correct: true)
        sut.questionAnswered(inRegion: region, correct: false)
        sut.questionAnswered(inRegion: region, correct: true)
        
        // Then
        let progress = sut.regionalProgress[region.id]
        XCTAssertEqual(progress?.answeredCount, 3)
        XCTAssertEqual(progress?.correctCount, 2)
    }
    
    func test_questionAnswered_createsProgressIfNotExists() {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        XCTAssertNil(sut.regionalProgress[region.id])
        
        // When
        sut.questionAnswered(inRegion: region, correct: true)
        
        // Then
        XCTAssertNotNil(sut.regionalProgress[region.id])
    }
    
    func test_questionAnswered_debouncesPersistence() async {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        mockDataService.updateRegionProgressCalls = []
        
        // When (rapid answers)
        sut.questionAnswered(inRegion: region, correct: true)
        sut.questionAnswered(inRegion: region, correct: true)
        sut.questionAnswered(inRegion: region, correct: true)
        
        try? await Task.sleep(nanoseconds: 300_000_000)  // 300ms (before debounce)
        
        // Then (no persist yet)
        XCTAssertEqual(mockDataService.updateRegionProgressCalls.count, 0)
        
        // When (wait for debounce)
        try? await Task.sleep(nanoseconds: 300_000_000)  // Total 600ms
        
        // Then (single persist)
        XCTAssertEqual(mockDataService.updateRegionProgressCalls.count, 1)
        let persisted = mockDataService.updateRegionProgressCalls[0]
        XCTAssertEqual(persisted.answeredCount, 3)
        XCTAssertEqual(persisted.correctCount, 3)
    }
    
    func test_questionAnswered_persistenceHandlesError() async {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        mockDataService.shouldThrowError = true
        mockDataService.errorToThrow = .databaseError
        
        // When
        sut.questionAnswered(inRegion: region, correct: true)
        try? await Task.sleep(nanoseconds: 700_000_000)  // Wait for debounce + persist
        
        // Then
        XCTAssertEqual(sut.error, .progressPersistFailed)
        // But local progress still updated
        XCTAssertEqual(sut.regionalProgress[region.id]?.answeredCount, 1)
    }
    
    // MARK: - Toggle Favorite
    
    func test_toggleFavorite_togglesFavoriteFlag() {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [], isFavorite: false)
        mockDataService.regionsToReturn = [region]
        sut.loadRegions()
        
        // When
        sut.toggleFavorite(region)
        
        // Then
        XCTAssertTrue(sut.favoriteRegions.contains { $0.id == "BY" })
    }
    
    func test_toggleFavorite_updatesDataService() {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [], isFavorite: false)
        mockDataService.regionsToReturn = [region]
        mockDataService.updatedRegions = []
        sut.loadRegions()
        
        // When
        sut.toggleFavorite(region)
        
        // Then
        XCTAssertTrue(mockDataService.updatedRegions.contains { $0.id == "BY" && $0.isFavorite })
    }
    
    func test_toggleFavorite_handlesUpdateError() {
        // Given
        let region = PLZRegion(id: "BY", name: "Bayern", plzRanges: [])
        mockDataService.shouldThrowError = true
        mockDataService.errorToThrow = .databaseError
        
        // When
        sut.toggleFavorite(region)
        
        // Then
        XCTAssertEqual(sut.error, .updateFailed)
    }
    
    // MARK: - Load Regions
    
    func test_loadRegions_sortsAlphabetically() {
        // Given
        let regions = [
            PLZRegion(id: "ZH", name: "Zürich", plzRanges: []),  // Would be sorted last
            PLZRegion(id: "BY", name: "Bayern", plzRanges: []),
            PLZRegion(id: "AW", name: "Appenzell Ausserrhoden", plzRanges: [])
        ]
        mockDataService.regionsToReturn = regions
        
        // When
        sut.loadRegions()
        
        // Then
        XCTAssertEqual(sut.allRegions[0].name, "Appenzell Ausserrhoden")
        XCTAssertEqual(sut.allRegions[1].name, "Bayern")
        XCTAssertEqual(sut.allRegions[2].name, "Zürich")
    }
    
    func test_loadRegions_clearsErrorOnSuccess() {
        // Given
        mockDataService.shouldThrowError = true
        sut.loadRegions()  // Causes error
        XCTAssertNotNil(sut.error)
        
        // When
        mockDataService.shouldThrowError = false
        mockDataService.regionsToReturn = [PLZRegion(id: "BY", name: "Bayern", plzRanges: [])]
        sut.loadRegions()
        
        // Then
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Cleanup
    
    func test_deinit_cancelsLocationTask() {
        // Given
        mockLocationService.shouldDelay = true
        sut.requestLocation()
        
        // When (deinit)
        var viewModel: LocationFilterViewModel? = sut
        sut = nil
        viewModel = nil
        
        // Then (no assertion, just verify no crash/memory leak)
        XCTAssertNil(viewModel)
    }
}