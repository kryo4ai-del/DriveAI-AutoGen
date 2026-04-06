import Foundation

// MARK: - MockLocationDataService

final class MockLocationDataService: LocationDataServiceProtocol {
    var stubbedRegion: PostalCodeRegion?
    var stubbedError: LocationError?
    var searchResults: [PostalCodeRegion] = []
    var initialized = true

    func getRegion(plz: String) async throws -> PostalCodeRegion {
        if let error = stubbedError { throw error }
        guard let region = stubbedRegion else {
            throw LocationError.notFound
        }
        return region
    }

    func searchByName(_ query: String) async throws -> [PostalCodeRegion] {
        return searchResults
    }

    func listByState(_ state: String) async throws -> [PostalCodeRegion] {
        return searchResults.filter { $0.state.rawValue == state || $0.state.name == state }
    }

    func getAllStates() async throws -> [String] {
        return Array(Set(searchResults.map { $0.state.rawValue })).sorted()
    }

    func isInitialized() -> Bool {
        return initialized
    }
}