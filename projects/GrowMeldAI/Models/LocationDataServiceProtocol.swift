import Foundation

// MARK: - Protocols

/// Protocol for location data persistence and retrieval
protocol LocationDataServiceProtocol: Sendable {
    func loadAllLocations() async throws -> [Location]
    func searchLocations(by query: String, state: String?) async throws -> [Location]
    func getLocation(by postalCode: String) async throws -> Location?
    func getStates() async throws -> [String]
}

// MARK: - Thread-Safe Cache Actor

/// Actor providing thread-safe access to cached locations
private actor LocationCache {
    private var locations: [Location]?
    
    func getCached() -> [Location]? {
        locations
    }
    
    func setCached(_ newLocations: [Location]) {
        locations = newLocations
    }
    
    func clear() {
        locations = nil
    }
}

// MARK: - Service Implementation

/// Local data service using in-memory cache + JSON bundle

// MARK: - Error Types
