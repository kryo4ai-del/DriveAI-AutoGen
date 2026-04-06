// Tests/LocationRepositoryTests.swift
@MainActor
final class LocationRepositoryTests: XCTestCase {
    var mockService: MockLocationDataService!
    var repository: LocationRepository!
    
    override func setUp() {
        mockService = MockLocationDataService()
        repository = LocationRepository(dataService: mockService)
    }
    
    func testLookupPostalCodeSuccess() async throws {
        mockService.stubbedRegion = .mock(plz: "10115")
        
        let region = try await repository.lookupPostalCode("10115")
        
        XCTAssertEqual(region.id, "10115")
        XCTAssertEqual(region.name, "Berlin Mitte")
    }
    
    func testLookupInvalidFormat() async {
        await XCTAssertThrowsError(
            try await repository.lookupPostalCode("invalid")
        ) { error in
            XCTAssertTrue(error is LocationError)
        }
    }
}