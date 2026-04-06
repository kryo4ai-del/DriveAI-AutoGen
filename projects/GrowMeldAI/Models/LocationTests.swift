import XCTest
@testable import DriveAI

final class LocationTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testLocationInitialization() {
        // Arrange
        let postalCode = "80331"
        let city = "München"
        let state = "Bayern"
        let region = "BY01"
        
        // Act
        let location = Location(
            postalCode: postalCode,
            city: city,
            state: state,
            region: region
        )
        
        // Assert
        XCTAssertEqual(location.postalCode, postalCode)
        XCTAssertEqual(location.city, city)
        XCTAssertEqual(location.state, state)
        XCTAssertEqual(location.region, region)
        XCTAssertEqual(location.id, postalCode) // ID should equal postal code
    }
    
    // MARK: - Display Name Tests
    
    func testDisplayNameFormatting() {
        // Arrange
        let location = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        
        // Act
        let displayName = location.displayName
        
        // Assert
        XCTAssertEqual(displayName, "80331 München, Bayern")
    }
    
    func testDisplayNameWithSpecialCharacters() {
        // Arrange
        let location = Location(
            postalCode: "52070",
            city: "Aachen",
            state: "Nordrhein-Westfalen",
            region: "NRW01"
        )
        
        // Act
        let displayName = location.displayName
        
        // Assert
        XCTAssertEqual(displayName, "52070 Aachen, Nordrhein-Westfalen")
        XCTAssertTrue(displayName.contains("-"))
    }
    
    // MARK: - Search Content Tests
    
    func testSearchableContentIsLowercased() {
        // Arrange
        let location = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        
        // Act
        let searchContent = location.searchableContent
        
        // Assert
        XCTAssertEqual(searchContent, "80331 münchen bayern by01")
        XCTAssertFalse(searchContent.contains("M"))
        XCTAssertFalse(searchContent.contains("B"))
    }
    
    func testSearchableContentIncludesAllFields() {
        // Arrange
        let location = Location(
            postalCode: "10115",
            city: "Berlin",
            state: "Berlin",
            region: "BE01"
        )
        
        // Act
        let searchContent = location.searchableContent
        
        // Assert
        XCTAssertTrue(searchContent.contains("10115"))
        XCTAssertTrue(searchContent.contains("berlin"))
        XCTAssertTrue(searchContent.contains("be01"))
    }
    
    // MARK: - Hashable Tests
    
    func testLocationHashable() {
        // Arrange
        let location1 = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        let location2 = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        
        // Act
        let set = Set([location1, location2])
        
        // Assert
        XCTAssertEqual(set.count, 1) // Duplicates removed
    }
    
    func testLocationHashBasedOnId() {
        // Arrange
        let location1 = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        let location2 = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY02" // Different region
        )
        
        // Act & Assert
        XCTAssertEqual(location1, location2) // Equal because ID (postalCode) is same
    }
    
    // MARK: - Equatable Tests
    
    func testLocationEquality() {
        // Arrange
        let location1 = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        let location2 = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        
        // Act & Assert
        XCTAssertEqual(location1, location2)
    }
    
    func testLocationInequalityDifferentPostalCode() {
        // Arrange
        let location1 = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        let location2 = Location(
            postalCode: "80332",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        
        // Act & Assert
        XCTAssertNotEqual(location1, location2)
    }
    
    // MARK: - Codable Tests
    
    func testLocationEncodingAndDecoding() throws {
        // Arrange
        let location = Location(
            postalCode: "80331",
            city: "München",
            state: "Bayern",
            region: "BY01"
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // Act
        let encoded = try encoder.encode(location)
        let decoded = try decoder.decode(Location.self, from: encoded)
        
        // Assert
        XCTAssertEqual(decoded, location)
    }
    
    // MARK: - Edge Cases
    
    func testLocationWithEmptyStrings() {
        // Arrange & Act
        let location = Location(
            postalCode: "",
            city: "",
            state: "",
            region: ""
        )
        
        // Assert
        XCTAssertEqual(location.id, "")
        XCTAssertEqual(location.displayName, " , ")
    }
    
    func testLocationWithVeryLongStrings() {
        // Arrange
        let longString = String(repeating: "A", count: 1000)
        
        // Act
        let location = Location(
            postalCode: "80331",
            city: longString,
            state: longString,
            region: longString
        )
        
        // Assert
        XCTAssertEqual(location.city, longString)
        XCTAssertTrue(location.displayName.count > 2000)
    }
}