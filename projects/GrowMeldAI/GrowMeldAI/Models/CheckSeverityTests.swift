import XCTest
@testable import DriveAI

final class CheckSeverityTests: XCTestCase {
    
    // MARK: - Comparable
    
    func test_checkSeverity_comparesCorrectly() {
        XCTAssertLessThan(CheckSeverity.low, CheckSeverity.medium)
        XCTAssertLessThan(CheckSeverity.medium, CheckSeverity.high)
        XCTAssertLessThan(CheckSeverity.low, CheckSeverity.high)
    }
    
    func test_checkSeverity_sortsArray() {
        let unsorted = [
            CheckSeverity.low,
            CheckSeverity.high,
            CheckSeverity.medium,
            CheckSeverity.low
        ]
        
        let sorted = unsorted.sorted()
        
        XCTAssertEqual(sorted, [
            .low, .low, .medium, .high
        ])
    }
    
    // MARK: - Localization
    
    func test_checkSeverity_localizedLabels() {
        XCTAssertEqual(CheckSeverity.low.localizedLabel, "Info")
        XCTAssertEqual(CheckSeverity.medium.localizedLabel, "Hinweis")
        XCTAssertEqual(CheckSeverity.high.localizedLabel, "Wichtig")
    }
    
    // MARK: - Codable
    
    func test_checkSeverity_encodesAsInteger() throws {
        let severity = CheckSeverity.medium
        let encoded = try JSONEncoder().encode(severity)
        let decoded = try JSONDecoder().decode(CheckSeverity.self, from: encoded)
        
        XCTAssertEqual(decoded, .medium)
        XCTAssertEqual(decoded.rawValue, 2)
    }
    
    func test_checkSeverity_decodesFromRawValue() throws {
        let json = "3".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(CheckSeverity.self, from: json)
        
        XCTAssertEqual(decoded, .high)
    }
    
    // MARK: - CaseIterable
    
    func test_checkSeverity_allCases() {
        let allCases = CheckSeverity.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.low))
        XCTAssertTrue(allCases.contains(.medium))
        XCTAssertTrue(allCases.contains(.high))
    }
}