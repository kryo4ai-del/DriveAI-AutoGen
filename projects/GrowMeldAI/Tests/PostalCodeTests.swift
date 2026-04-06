import XCTest
@testable import DriveAI

final class PostalCodeTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testPostalCode_ValidInitialization() {
        let plz = PostalCode(
            id: "DE_10115",
            plz: "10115",
            city: "Berlin",
            district: "Mitte",
            state: "Berlin",
            country: "DE",
            latitude: 52.5200,
            longitude: 13.4050
        )
        
        XCTAssertEqual(plz.plz, "10115")
        XCTAssertEqual(plz.city, "Berlin")
        XCTAssertEqual(plz.country, "DE")
        XCTAssertNil(plz.district.isEmpty ? nil : plz.district)
    }
    
    func testPostalCode_DisplayName_WithState() {
        let plz = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        
        XCTAssertEqual(plz.displayName, "10115 Berlin, Berlin")
    }
    
    func testPostalCode_FullDisplayName_WithDistrict() {
        let plz = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: "Mitte", state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        
        XCTAssertEqual(plz.fullDisplayName, "10115, Berlin, Mitte, Berlin")
    }
    
    // MARK: - Format Validation
    
    func testIsValidFormat_GermanPLZ_Success() {
        XCTAssertTrue(PostalCode.isValidFormat("10115"))
        XCTAssertTrue(PostalCode.isValidFormat("50667"))
        XCTAssertTrue(PostalCode.isValidFormat("80331"))
    }
    
    func testIsValidFormat_AustrianPLZ_Success() {
        XCTAssertTrue(PostalCode.isValidFormat("1010"))
        XCTAssertTrue(PostalCode.isValidFormat("5020"))
        XCTAssertTrue(PostalCode.isValidFormat("6900"))
    }
    
    func testIsValidFormat_SwissPLZ_Success() {
        XCTAssertTrue(PostalCode.isValidFormat("8000"))
        XCTAssertTrue(PostalCode.isValidFormat("3011"))
        XCTAssertTrue(PostalCode.isValidFormat("1201"))
    }
    
    func testIsValidFormat_Whitespace_Trimmed() {
        XCTAssertTrue(PostalCode.isValidFormat("  10115  "))
        XCTAssertTrue(PostalCode.isValidFormat("\t5020\n"))
    }
    
    // MARK: - Invalid Formats
    
    func testIsValidFormat_TooShort_Fails() {
        XCTAssertFalse(PostalCode.isValidFormat("1011"))  // 4 digits, not 5
        XCTAssertFalse(PostalCode.isValidFormat("101"))   // 3 digits
    }
    
    func testIsValidFormat_TooLong_Fails() {
        XCTAssertFalse(PostalCode.isValidFormat("101150"))  // 6 digits
        XCTAssertFalse(PostalCode.isValidFormat("10115000"))
    }
    
    func testIsValidFormat_ContainsLetters_Fails() {
        XCTAssertFalse(PostalCode.isValidFormat("1011A"))
        XCTAssertFalse(PostalCode.isValidFormat("SW-8000"))
    }
    
    func testIsValidFormat_ContainsSpecialChars_Fails() {
        XCTAssertFalse(PostalCode.isValidFormat("101-15"))
        XCTAssertFalse(PostalCode.isValidFormat("10115."))
    }
    
    func testIsValidFormat_Empty_Fails() {
        XCTAssertFalse(PostalCode.isValidFormat(""))
        XCTAssertFalse(PostalCode.isValidFormat("   "))
    }
    
    // MARK: - Codable (JSON Serialization)
    
    func testPostalCode_JSONEncoding_Success() throws {
        let plz = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: "Mitte", state: "Berlin", country: "DE",
            latitude: 52.5200, longitude: 13.4050
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(plz)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["plz"] as? String, "10115")
        XCTAssertEqual(json?["city"] as? String, "Berlin")
        XCTAssertEqual(json?["country"] as? String, "DE")
    }
    
    func testPostalCode_JSONDecoding_Success() throws {
        let jsonData = """
        {
            "id": "DE_10115",
            "plz": "10115",
            "city": "Berlin",
            "district": "Mitte",
            "state": "Berlin",
            "country": "DE",
            "latitude": 52.5200,
            "longitude": 13.4050
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let plz = try decoder.decode(PostalCode.self, from: jsonData)
        
        XCTAssertEqual(plz.plz, "10115")
        XCTAssertEqual(plz.city, "Berlin")
    }
    
    // MARK: - Hashable & Identifiable
    
    func testPostalCode_Hashable_ConsistentAcrossCalls() {
        let plz1 = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        let plz2 = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        
        XCTAssertEqual(plz1.hashValue, plz2.hashValue)
    }
    
    func testPostalCode_Equatable_SameContent_IsEqual() {
        let plz1 = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        let plz2 = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        
        XCTAssertEqual(plz1, plz2)
    }
    
    func testPostalCode_Sendable_CompileCheck() {
        // This is a compile-time check — if PostalCode is Sendable,
        // it can be passed to actor-isolated methods without warning
        func acceptsSendable<T: Sendable>(_: T) {}
        
        let plz = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        
        acceptsSendable(plz)  // ✅ Should compile without warnings
    }
    
    // MARK: - Edge Cases
    
    func testPostalCode_DistrictOptional_NilHandled() {
        let plzWithoutDistrict = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 52.52, longitude: 13.40
        )
        
        XCTAssertNil(plzWithoutDistrict.district)
        XCTAssertEqual(plzWithoutDistrict.fullDisplayName, "10115, Berlin, Berlin")
    }
    
    func testPostalCode_LargeLatitudeLongitude_Handled() {
        let plz = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: 85.0511,  // Valid: close to North Pole
            longitude: 179.9999
        )
        
        XCTAssertEqual(plz.latitude, 85.0511)
        XCTAssertEqual(plz.longitude, 179.9999)
    }
    
    func testPostalCode_NegativeCoordinates_Handled() {
        let plz = PostalCode(
            id: "DE_10115", plz: "10115", city: "Berlin",
            district: nil, state: "Berlin", country: "DE",
            latitude: -33.8688,  // Sydney, Australia (test edge case)
            longitude: 151.2093
        )
        
        XCTAssertTrue(plz.latitude < 0)
        XCTAssertTrue(plz.longitude > 0)
    }
}