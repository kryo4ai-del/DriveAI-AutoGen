import XCTest
@testable import DriveAI

final class UserLocationContextTests: XCTestCase {
    
    func test_isValid_validContext() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!
        let context = UserLocationContext(
            postalCode: "80001",
            region: region,
            latitude: 48.1351,
            longitude: 11.5820,
            timestamp: Date()
        )
        
        XCTAssertTrue(context.isValid)
    }
    
    func test_isValid_invalidPLZ() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!
        let context = UserLocationContext(
            postalCode: "INVALID",
            region: region,
            latitude: nil,
            longitude: nil,
            timestamp: Date()
        )
        
        XCTAssertFalse(context.isValid)
    }
    
    func test_isValid_plzMismatchesRegion() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!  // Bavaria
        let context = UserLocationContext(
            postalCode: "10115",  // Berlin PLZ
            region: region,
            latitude: nil,
            longitude: nil,
            timestamp: Date()
        )
        
        XCTAssertFalse(context.isValid)
    }
    
    func test_codable_roundTrip() throws {
        let region = PLZRegion.allRegions.first { $0.id == "HH" }!
        let original = UserLocationContext(
            postalCode: "20001",
            region: region,
            latitude: 53.5511,
            longitude: 10.0119,
            timestamp: Date()
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserLocationContext.self, from: encoded)
        
        XCTAssertEqual(original.postalCode, decoded.postalCode)
        XCTAssertEqual(original.region, decoded.region)
    }
}