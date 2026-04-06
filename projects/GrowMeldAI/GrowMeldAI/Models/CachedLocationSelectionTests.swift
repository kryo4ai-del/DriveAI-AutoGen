import XCTest
@testable import DriveAI

final class CachedLocationSelectionTests: XCTestCase {
    
    let testLocation = Location(
        postalCode: "80331",
        city: "München",
        state: "Bayern",
        region: "BY01"
    )
    
    // MARK: - Staleness Tests
    
    func testFreshSelectionIsNotStale() {
        // Arrange
        let selection = CachedLocationSelection(
            location: testLocation,
            selectedAt: Date()
        )
        
        // Act & Assert
        XCTAssertFalse(selection.isStale)
    }
    
    func testSelectionFrom29DaysAgoIsNotStale() {
        // Arrange
        let twentyNineDaysAgo = Date(timeIntervalSinceNow: -29 * 24 * 3600)
        let selection = CachedLocationSelection(
            location: testLocation,
            selectedAt: twentyNineDaysAgo
        )
        
        // Act & Assert
        XCTAssertFalse(selection.isStale)
    }
    
    func testSelectionFrom30DaysAgoIsStale() {
        // Arrange
        let thirtyDaysAgo = Date(timeIntervalSinceNow: -30 * 24 * 3600)
        let selection = CachedLocationSelection(
            location: testLocation,
            selectedAt: thirtyDaysAgo
        )
        
        // Act & Assert
        XCTAssertTrue(selection.isStale)
    }
    
    func testSelectionFrom31DaysAgoIsStale() {
        // Arrange
        let thirtyOneDaysAgo = Date(timeIntervalSinceNow: -31 * 24 * 3600)
        let selection = CachedLocationSelection(
            location: testLocation,
            selectedAt: thirtyOneDaysAgo
        )
        
        // Act & Assert
        XCTAssertTrue(selection.isStale)
    }
    
    // MARK: - Codable Tests
    
    func testCachedLocationSelectionEncodingDecoding() throws {
        // Arrange
        let selection = CachedLocationSelection(
            location: testLocation,
            selectedAt: Date()
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // Act
        let encoded = try encoder.encode(selection)
        let decoded = try decoder.decode(CachedLocationSelection.self, from: encoded)
        
        // Assert
        XCTAssertEqual(decoded.location, selection.location)
        // Note: Date equality might have rounding differences
        XCTAssertEqual(
            Int(decoded.selectedAt.timeIntervalSince1970),
            Int(selection.selectedAt.timeIntervalSince1970)
        )
    }
    
    // MARK: - Equatable Tests
    
    func testCachedLocationSelectionEquality() {
        // Arrange
        let date = Date()
        let selection1 = CachedLocationSelection(
            location: testLocation,
            selectedAt: date
        )
        let selection2 = CachedLocationSelection(
            location: testLocation,
            selectedAt: date
        )
        
        // Act & Assert
        XCTAssertEqual(selection1, selection2)
    }
    
    func testCachedLocationSelectionInequalityDifferentLocation() {
        // Arrange
        let date = Date()
        let location2 = Location(
            postalCode: "10115",
            city: "Berlin",
            state: "Berlin",
            region: "BE01"
        )
        let selection1 = CachedLocationSelection(
            location: testLocation,
            selectedAt: date
        )
        let selection2 = CachedLocationSelection(
            location: location2,
            selectedAt: date
        )
        
        // Act & Assert
        XCTAssertNotEqual(selection1, selection2)
    }
}