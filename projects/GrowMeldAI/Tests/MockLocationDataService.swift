final class MockLocationDataService: LocationDataServiceProtocol {
    var stubbedRegion: PostalCodeRegion?
    var stubbedError: LocationError?
    var searchResults: [PostalCodeRegion] = []
    var initialized = true
    
    func getRegion(plz: String) async throws -> PostalCodeRegion {
        if let error = stubbedError { throw error }
        guard let region = stubbedRegion else {
            throw LocationError.plzNotFound(plz)
        }
        return region
    }
    
    func searchByName(_ query: String) async throws -> [PostalCodeRegion] {
        searchResults
    }
    
    func listByState(_ state: String) async throws -> [PostalCodeRegion] {
        searchResults.filter { $0.state == state }
    }
    
    func getAllStates() async throws -> [String] {
        Array(Set(searchResults.map { $0.state })).sorted()
    }
    
    func isInitialized() -> Bool {
        initialized
    }
}

// Test example:
@MainActor
final class LocationPickerViewModelTests: XCTestCase {
    func testSearchSuccess() async {
        let mock = MockLocationDataService()
        mock.stubbedRegion = .mock(plz: "10115")
        
        let repo = LocationRepository(dataService: mock)
        let vm = LocationPickerViewModel(repository: repo)
        
        await vm.search("10115")
        
        guard case .loaded(let region) = vm.state else {
            XCTFail("Expected loaded state")
            return
        }
        
        XCTAssertEqual(region.id, "10115")
    }
}