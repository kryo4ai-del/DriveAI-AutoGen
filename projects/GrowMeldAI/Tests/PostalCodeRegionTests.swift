import XCTest
@testable import DriveAI

final class PostalCodeRegionTests: XCTestCase {
    
    // MARK: - Initialization & Validation
    
    func test_init_stripsWhitespace() {
        let region = PostalCodeRegion(
            plz: "  10115  ",
            city: "  Berlin  ",
            state: .de_berlin,
            country: .de
        )
        
        XCTAssertEqual(region.plz, "10115")
        XCTAssertEqual(region.city, "Berlin")
    }
    
    func test_init_with_district() {
        let region = PostalCodeRegion(
            plz: "20095",
            city: "Hamburg",
            state: .de_hamburg,
            country: .de,
            district: "Altstadt"
        )
        
        XCTAssertEqual(region.district, "Altstadt")
    }
    
    func test_init_defaultRegionType() {
        let region = PostalCodeRegion(
            plz: "10115",
            city: "Berlin",
            state: .de_berlin,
            country: .de
        )
        
        XCTAssertEqual(region.regionType, .municipality)
    }
    
    func test_init_customRegionType() {
        let region = PostalCodeRegion(
            plz: "10115",
            city: "Berlin",
            state: .de_berlin,
            country: .de,
            regionType: .city
        )
        
        XCTAssertEqual(region.regionType, .city)
    }
    
    // MARK: - Display Names & Accessibility
    
    func test_shortName_format() {
        let region = PostalCodeRegion.berlinTest()
        XCTAssertEqual(region.shortName, "10115 Berlin")
    }
    
    func test_displayName_withoutCountry() {
        let region = PostalCodeRegion.berlinTest()
        let name = region.displayName(showCountry: false)
        
        XCTAssertEqual(name, "10115 Berlin")
        XCTAssertFalse(name.contains("Deutschland"))
    }
    
    func test_displayName_withCountry() {
        let region = PostalCodeRegion.berlinTest()
        let name = region.displayName(showCountry: true)
        
        XCTAssertEqual(name, "10115 Berlin, Deutschland")
    }
    
    func test_displayName_withDistrict_withoutCountry() {
        let region = PostalCodeRegion(
            plz: "20095",
            city: "Hamburg",
            state: .de_hamburg,
            country: .de,
            district: "Altstadt"
        )
        
        let name = region.displayName(showCountry: false)
        XCTAssertTrue(name.contains("Altstadt"))
        XCTAssertFalse(name.contains("Deutschland"))
    }
    
    func test_displayName_withDistrict_withCountry() {
        let region = PostalCodeRegion(
            plz: "20095",
            city: "Hamburg",
            state: .de_hamburg,
            country: .de,
            district: "Altstadt"
        )
        
        let name = region.displayName(showCountry: true)
        XCTAssertTrue(name.contains("Altstadt"))
        XCTAssertTrue(name.contains("Deutschland"))
    }
    
    func test_accessibilityLabel_complete() {
        let region = PostalCodeRegion.berlinTest()
        let label = region.accessibilityLabel
        
        XCTAssertTrue(label.contains("10115"))
        XCTAssertTrue(label.contains("Berlin"))
        XCTAssertTrue(label.contains("Deutschland"))
    }
    
    func test_accessibilityLabel_includesState() {
        let region = PostalCodeRegion.berlinTest()
        let label = region.accessibilityLabel
        
        XCTAssertTrue(label.contains("Berlin")) // State display name
    }
    
    // MARK: - Equatable & Hashable
    
    func test_equatable_sameValues() {
        let region1 = PostalCodeRegion.berlinTest()
        let region2 = PostalCodeRegion.berlinTest()
        
        XCTAssertEqual(region1, region2)
    }
    
    func test_equatable_differentPLZ() {
        let region1 = PostalCodeRegion.berlinTest()
        let region2 = PostalCodeRegion(
            plz: "10116",
            city: "Berlin",
            state: .de_berlin,
            country: .de
        )
        
        XCTAssertNotEqual(region1, region2)
    }
    
    func test_equatable_differentCity() {
        let region1 = PostalCodeRegion.berlinTest()
        let region2 = PostalCodeRegion(
            plz: "10115",
            city: "München",
            state: .de_berlin,
            country: .de
        )
        
        XCTAssertNotEqual(region1, region2)
    }
    
    func test_equatable_differentCountry() {
        let region1 = PostalCodeRegion.berlinTest()
        let region2 = PostalCodeRegion(
            plz: "10115",
            city: "Berlin",
            state: .de_berlin,
            country: .at
        )
        
        XCTAssertNotEqual(region1, region2)
    }
    
    func test_hashable_canUseInSet() {
        let region1 = PostalCodeRegion.berlinTest()
        let region2 = PostalCodeRegion.berlinTest() // Same as region1
        let region3 = PostalCodeRegion.viennaTest()
        
        var set: Set<PostalCodeRegion> = [region1, region2, region3]
        XCTAssertEqual(set.count, 2) // Berlin counted once, Vienna once
    }
    
    func test_hashable_canUseAsDictKey() {
        let region1 = PostalCodeRegion.berlinTest()
        let region2 = PostalCodeRegion.viennaTest()
        
        var dict: [PostalCodeRegion: String] = [:]
        dict[region1] = "Berlin"
        dict[region2] = "Wien"
        
        XCTAssertEqual(dict[region1], "Berlin")
        XCTAssertEqual(dict[region2], "Wien")
    }
    
    // MARK: - Sendable Compliance
    
    func test_sendable_canPassToActor() async {
        let region = PostalCodeRegion.berlinTest()
        let result = await sendableCheck(region)
        
        XCTAssertEqual(result.city, "Berlin")
    }
    
    nonisolated private func sendableCheck(_ region: PostalCodeRegion) async -> PostalCodeRegion {
        region
    }
    
    // MARK: - Codable
    
    func test_codable_encode_complete() throws {
        let region = PostalCodeRegion.berlinTest()
        let data = try JSONEncoder().encode(region)
        
        XCTAssertGreater(data.count, 0)
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["plz"] as? String, "10115")
        XCTAssertEqual(json?["city"] as? String, "Berlin")
    }
    
    func test_codable_encode_withDistrict() throws {
        let region = PostalCodeRegion(
            plz: "20095",
            city: "Hamburg",
            state: .de_hamburg,
            country: .de,
            district: "Altstadt"
        )
        
        let data = try JSONEncoder().encode(region)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["district"] as? String, "Altstadt")
    }
    
    func test_codable_decode() throws {
        let region = PostalCodeRegion.berlinTest()
        let data = try JSONEncoder().encode(region)
        let decoded = try JSONDecoder().decode(PostalCodeRegion.self, from: data)
        
        XCTAssertEqual(decoded, region)
        XCTAssertEqual(decoded.plz, "10115")
        XCTAssertEqual(decoded.city, "Berlin")
    }
    
    func test_codable_roundtrip_allCountries() throws {
        let regions = [
            PostalCodeRegion.berlinTest(),
            PostalCodeRegion.viennaTest(),
            PostalCodeRegion.zurichTest()
        ]
        
        for original in regions {
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(PostalCodeRegion.self, from: data)
            XCTAssertEqual(decoded, original)
        }
    }
    
    // MARK: - Edge Cases
    
    func test_init_emptyDistrict() {
        let region = PostalCodeRegion(
            plz: "10115",
            city: "Berlin",
            state: .de_berlin,
            country: .de,
            district: "   "
        )
        
        XCTAssertEqual(region.district, "")
    }
    
    func test_init_nilDistrict() {
        let region = PostalCodeRegion(
            plz: "10115",
            city: "Berlin",
            state: .de_berlin,
            country: .de,
            district: nil
        )
        
        XCTAssertNil(region.district)
    }
}