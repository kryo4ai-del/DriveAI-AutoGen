// Tests/LocationDataServiceTests.swift
@MainActor
final class LocationDataServiceTests: XCTestCase {
    var sut: LocationDataService!
    
    override func setUp() async throws {
        sut = try await LocationDataService(bundleResourceName: "postal_codes_test")
    }
    
    func testFetchPostalCode_ValidPLZ_ReturnsResult() async {
        let result = await sut.postalCode(for: "10115")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.city, "Berlin")
    }
    
    func testFetchPostalCode_InvalidPLZ_ReturnsNil() async {
        let result = await sut.postalCode(for: "99999")
        XCTAssertNil(result)
    }
    
    func testPostalCodeSearch_PrefixMatch() async {
        let results = await sut.postalCodes(matching: "1011", limit: 5)
        XCTAssertFalse(results.isEmpty)
        XCTAssert(results.allSatisfy { $0.plz.hasPrefix("1011") })
    }
}

// Tests/LocationSelectionViewModelTests.swift
@MainActor
final class LocationSelectionViewModelTests: XCTestCase {
    var viewModel: LocationSelectionViewModel!
    var mockLocationDataService: MockLocationDataService!
    
    override func setUp() async throws {
        mockLocationDataService = MockLocationDataService()
        viewModel = LocationSelectionViewModel(
            locationDataService: mockLocationDataService,
            deviceLocationService: MockDeviceLocationService()
        )
    }
    
    func testSelectPostalCode_UpdatesSelectedRegion() async {
        let plz = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin", district: nil,
            state: "Berlin", country: "DE", latitude: 52.52, longitude: 13.405
        )
        
        viewModel.selectPostalCode(plz)
        
        XCTAssertEqual(viewModel.selectedPostalCode, plz)
        // Wait for async region fetch
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNotNil(viewModel.selectedRegion)
    }
}