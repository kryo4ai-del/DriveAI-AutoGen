struct RegionManifest: Codable {
    static let currentVersion = "1.0.0"
    
    let version: String
    let lastUpdated: Date
    let regions: [RegionData]
    
    enum CodingKeys: String, CodingKey {
        case version, lastUpdated, countryId, regions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        
        // Validate version compatibility
        guard version == Self.currentVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .version,
                in: container,
                debugDescription: "Unsupported manifest version: \(version)"
            )
        }
        
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        // ... rest of init
    }
}