actor GeolocationService {
    static let shared = GeolocationService()
    
    private let geoipService: GeoIPService  // e.g., MaxMind, ip2location
    private let cache = NSCache<NSString, NSString>()
    
    func detectJurisdiction() async -> ComplianceProfile.Jurisdiction {
        // Step 1: Try device locale (fastest, less reliable)
        if let jurisdiction = jurisdictionFromDeviceLocale() {
            return jurisdiction
        }
        
        // Step 2: Try IP-based geolocation (requires backend or third-party service)
        do {
            let ipAddress = try await getPublicIPAddress()
            if let jurisdiction = try await geoipService.getJurisdiction(for: ipAddress) {
                return jurisdiction
            }
        } catch {
            // Fallback if IP detection fails
            print("Geolocation error: \(error)")
        }
        
        // Step 3: Fallback to conservative approach (assume EU if uncertain)
        // This favors user privacy — more restrictive compliance rules
        return .eu
    }
    
    private func jurisdictionFromDeviceLocale() -> ComplianceProfile.Jurisdiction? {
        guard let regionCode = Locale.current.region?.identifier else { return nil }
        
        // Curated list (maintained separately, not hardcoded)
        let euCountries: Set<String> = [
            "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE",
            "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV",
            "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK",
            "SI", "ES", "SE"
        ]
        
        if euCountries.contains(regionCode) {
            return .eu
        } else if regionCode == "US" {
            return .us
        }
        return nil
    }
    
    private func getPublicIPAddress() async throws -> String {
        // Call your backend endpoint: GET /api/v1/my-ip
        // Returns: { "ip": "1.2.3.4" }
        let url = URL(string: "https://api.driveai.app/my-ip")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(IPResponse.self, from: data)
        return response.ip
    }
}

struct IPResponse: Codable {
    let ip: String
}