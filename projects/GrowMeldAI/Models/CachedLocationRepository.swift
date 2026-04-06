import Foundation

protocol LocationRepository {
    func resolvePostalCode(_ plz: String, country: DACHCountry) async throws -> PostalCodeRegion
}

struct DACHCountry {
    let code: String

    static let germany = DACHCountry(code: "DE")
    static let austria = DACHCountry(code: "AT")
    static let switzerland = DACHCountry(code: "CH")
}

final class PostalCodeRegion: NSObject {
    let plz: String
    let name: String
    let country: String

    init(plz: String, name: String, country: String) {
        self.plz = plz
        self.name = name
        self.country = country
    }
}

final class CachedLocationRepository: LocationRepository {
    private let underlying: LocationRepository
    private let cache = NSCache<NSString, PostalCodeRegion>()

    init(underlying: LocationRepository) {
        self.underlying = underlying
    }

    func resolvePostalCode(_ plz: String, country: DACHCountry) async throws -> PostalCodeRegion {
        let cacheKey = NSString(string: "\(country.code)-\(plz)")

        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        let result = try await underlying.resolvePostalCode(plz, country: country)
        cache.setObject(result, forKey: cacheKey)
        return result
    }
}