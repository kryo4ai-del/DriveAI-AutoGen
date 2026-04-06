final class MockLocationRepository: LocationRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var stubbedResults: [String: PostalCodeRegion] = [:]
    
    func reset() {
        lock.withLock {
            stubbedResults.removeAll()
        }
    }
    
    func resolvePostalCode(_ plz: String, country: DACHCountry) 
        async throws -> PostalCodeRegion {
        let key = "\(country.code)-\(plz)"
        return try lock.withLock {
            guard let region = stubbedResults[key] else {
                throw LocationError.init(
                    type: .notFound,
                    message: "PLZ '\(plz)' nicht in \(country.displayName) gefunden"
                )
            }
            return region
        }
    }
}