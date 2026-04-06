import Foundation

/// Represents a postal code region in DACH countries
struct PostalCodeRegion: Codable, Equatable, Hashable, Sendable {
    /// Postal code (PLZ) in local format
    let plz: String
    
    /// City/municipality name
    let city: String
    
    /// Federal state or canton
    let state: FederalState
    
    /// Country code
    let country: DACHCountry
    
    /// Region classification type
    let regionType: RegionType
    
    /// Optional district/Bezirk for larger cities
    let district: String?
    
    init(
        plz: String,
        city: String,
        state: FederalState,
        country: DACHCountry,
        regionType: RegionType = .municipality,
        district: String? = nil
    ) {
        self.plz = plz.trimmingCharacters(in: .whitespaces)
        self.city = city.trimmingCharacters(in: .whitespaces)
        self.state = state
        self.country = country
        self.regionType = regionType
        self.district = district?.trimmingCharacters(in: .whitespaces)
    }
    
    enum RegionType: String, Codable, Equatable, Sendable {
        case city = "city"
        case municipality = "municipality"
        case district = "district"
        case canton = "canton"
    }
}

// MARK: - Display & Accessibility

extension PostalCodeRegion {
    /// Display name with optional country context
    func displayName(showCountry: Bool = false) -> String {
        var result = shortName
        if showCountry {
            result += ", \(country.displayName)"
        }
        if let district = district {
            result += " (\(district))"
        }
        return result
    }
    
    /// Short display (e.g., "10115 Berlin")
    var shortName: String {
        "\(plz) \(city)"
    }
    
    /// VoiceOver accessibility label
    var accessibilityLabel: String {
        "Postleitzahl \(plz), Stadt \(city), \(state.displayName), \(country.displayName)"
    }
}

// MARK: - Test Fixtures

extension PostalCodeRegion {
    static func berlinTest() -> PostalCodeRegion {
        PostalCodeRegion(
            plz: "10115",
            city: "Berlin",
            state: .de_berlin,
            country: .de,
            regionType: .city
        )
    }
    
    static func viennaTest() -> PostalCodeRegion {
        PostalCodeRegion(
            plz: "1010",
            city: "Wien",
            state: .at_vienna,
            country: .at,
            regionType: .city
        )
    }
    
    static func zurichTest() -> PostalCodeRegion {
        PostalCodeRegion(
            plz: "8000",
            city: "Zürich",
            state: .ch_zurich,
            country: .ch,
            regionType: .city
        )
    }
}

// MARK: - Sorting & Filtering

extension [PostalCodeRegion] {
    /// Sort by state, then city
    func sortedByStateAndCity() -> [PostalCodeRegion] {
        sorted { a, b in
            (a.state.displayName, a.city) < (b.state.displayName, b.city)
        }
    }
    
    /// Filter by country
    func filtered(by country: DACHCountry) -> [PostalCodeRegion] {
        filter { $0.country == country }
    }
    
    /// Filter by state
    func filtered(by state: FederalState) -> [PostalCodeRegion] {
        filter { $0.state == state }
    }
}