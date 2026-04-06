extension PostalCodeRegion {
    /// Test fixture: Berlin, Germany (10115)
    /// Used in tests to verify German postal code handling
    static func berlinTest() -> PostalCodeRegion {
        PostalCodeRegion(
            plz: "10115",
            city: "Berlin",
            state: .de_berlin,
            country: .de,
            regionType: .city
        )
    }
    
    /// Test fixture: Vienna, Austria (1010)
    /// Used in tests to verify Austrian postal code handling
    static func viennaTest() -> PostalCodeRegion { ... }
}