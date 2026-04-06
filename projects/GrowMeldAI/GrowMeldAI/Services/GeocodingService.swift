// ❌ BEFORE
final class GeocodingService {
    private var regionCache: [GeoRegion] = []  // Data race!
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> GeoRegion {
        let regions = await loadRegionCache()
        // ...
    }
}