private actor CachedLocationStore {
    private var locations: [Location]?
    
    func getCached() -> [Location]? { locations }
    func setCached(_ locations: [Location]) { self.locations = locations }
}

final class LocationDataService: LocationDataServiceProtocol {
    private let store = CachedLocationStore()
    
    func loadAllLocations() async throws -> [Location] {
        if let cached = await store.getCached() {
            return cached
        }
        let loaded = try loadLocationsFromBundle()
        await store.setCached(loaded)
        return loaded
    }
}