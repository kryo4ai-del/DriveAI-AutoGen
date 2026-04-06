import Foundation

final class MockLocationRepository: LocationRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var stubbedResults: [String: PostalCodeRegion] = [:]

    func stub(_ region: PostalCodeRegion, forPLZ plz: String, country: DACHCountry) {
        let key = "\(country.code)-\(plz)"
        lock.lock()
        defer { lock.unlock() }
        stubbedResults[key] = region
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }
        stubbedResults.removeAll()
    }

    func resolvePostalCode(_ plz: String, country: DACHCountry) async throws -> PostalCodeRegion {
        lock.lock()
        defer { lock.unlock() }
        let key = "\(country.code)-\(plz)"
        guard let region = stubbedResults[key] else {
            throw LocationError.notFound("PLZ '\(plz)' nicht in \(country.displayName) gefunden")
        }
        return region
    }
}