import Foundation

/// Thread-safe, offline-first location data service
/// Uses actor isolation to prevent data races
actor LocationDataService {
    // In-memory indices for O(1) or O(n) lookups
    private var postalCodeMap: [String: PostalCode] = [:]  // key: "10115"
    private var regionMap: [String: Region] = [:]  // key: "DE_Berlin"
    private var cityIndex: [String: [PostalCode]] = [:]  // key: "BERLIN"
    
    private let bundleResourceName: String
    private var isInitialized: Bool = false
    
    init(bundleResourceName: String = "postal_codes") async throws {
        self.bundleResourceName = bundleResourceName
        try await loadDatabase()
        self.isInitialized = true
    }
    
    // MARK: - Public Query APIs
    
    /// Fetch postal code by exact PLZ match
    func postalCode(for plz: String) -> PostalCode? {
        let key = plz.trimmingCharacters(in: .whitespaces).uppercased()
        return postalCodeMap[key]
    }
    
    /// Fetch region metadata for a given PLZ
    func region(forPLZ plz: String) -> Region? {
        guard let postalCode = postalCode(for: plz) else { return nil }
        let regionKey = "\(postalCode.country)_\(postalCode.state)"
        return regionMap[regionKey]
    }
    
    /// Search postal codes by prefix or city name (debounced)
    func postalCodes(
        matching searchText: String,
        limit: Int = 5
    ) -> [PostalCode] {
        let search = searchText.trimmingCharacters(in: .whitespaces).uppercased()
        guard !search.isEmpty else { return [] }
        
        var results: [PostalCode] = []
        
        // 1. Exact PLZ prefix match (fastest — usually 0–3 results)
        let prefixMatches = postalCodeMap.values.filter { $0.plz.hasPrefix(search) }
        results.append(contentsOf: prefixMatches.prefix(limit))
        
        if results.count >= limit {
            return Array(results.prefix(limit))
        }
        
        // 2. City name match using index (O(1) lookup)
        if let cityResults = cityIndex[search] {
            results.append(contentsOf: cityResults.prefix(limit - results.count))
        } else {
            // 3. Partial city match (O(n) fallback)
            let partial = postalCodeMap.values.filter {
                $0.city.uppercased().contains(search)
            }
            results.append(contentsOf: partial.prefix(limit - results.count))
        }
        
        return Array(results.prefix(limit))
    }
    
    /// Get all supported regions (MVP: Germany only)
    func supportedRegions() -> [Region] {
        regionMap.values.filter { $0.isSupported }
    }
    
    /// Look up region by region code
    func region(byCode code: String) -> Region? {
        regionMap[code]
    }
    
    /// Get nearby regions within radius (km)
    func nearbyRegions(forPLZ plz: String, radiusKm: Int = 50) -> [Region] {
        guard let postalCode = postalCode(for: plz) else { return [] }
        
        let nearby = postalCodeMap.values.filter {
            haversineDistance(from: postalCode, to: $0) <= Double(radiusKm)
        }
        
        let uniqueRegions = Set(nearby.compactMap { pc in
            regionMap["\(pc.country)_\(pc.state)"]
        })
        
        return Array(uniqueRegions)
    }
    
    // MARK: - Private Helpers
    
    /// Load postal code and region data from bundle JSON
    private func loadDatabase() async throws {
        guard let url = Bundle.main.url(forResource: bundleResourceName, withExtension: "json") else {
            throw LocationError.databaseNotFound
        }
        
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(PostalCodeDatabase.self, from: data)
        
        // Build indices
        for plz in container.postalCodes {
            postalCodeMap[plz.plz.uppercased()] = plz
            
            let cityKey = plz.city.uppercased()
            cityIndex[cityKey, default: []].append(plz)
        }
        
        for region in container.regions {
            regionMap[region.code] = region
        }
    }
    
    /// Haversine distance between two coordinates (km)
    private func haversineDistance(from: PostalCode, to: PostalCode) -> Double {
        let earthRadiusKm = 6371.0
        
        let dLat = (to.latitude - from.latitude) * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(from.latitude * .pi / 180) * cos(to.latitude * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c
    }
}

// MARK: - Database Container Model

private struct PostalCodeDatabase: Codable {
    let postalCodes: [PostalCode]
    let regions: [Region]
}