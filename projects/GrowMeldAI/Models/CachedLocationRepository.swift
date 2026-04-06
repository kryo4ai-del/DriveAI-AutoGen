final class CachedLocationRepository: LocationRepository {
    private let underlying: LocationRepository
    private let cache = NSCache<NSString, PostalCodeRegion>()
    
    func resolvePostalCode(_ plz: String, country: DACHCountry) 
        async throws -> PostalCodeRegion {
        let cacheKey = "\(country.code)-\(plz)" as NSString
        
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }
        
        let result = try await underlying.resolvePostalCode(plz, country: country)
        cache.setObject(result, forKey: cacheKey)
        return result
    }
}