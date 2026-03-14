import XCTest
@testable import DriveAI

class ReadinessLevelTests: XCTestCase {
    
    // MARK: - from(percentage:)
    
    func test_fromPercentage_beginner() {
        XCTAssertEqual(ReadinessLevel.from(percentage: 0), .beginner)
        XCTAssertEqual(ReadinessLevel.from(percentage: 25), .beginner)
        XCTAssertEqual(ReadinessLevel.from(percentage: 49), .beginner)
    }
    
    func test_fromPercentage_intermediate() {
        XCTAssertEqual(ReadinessLevel.from(percentage: 50), .intermediate)
        XCTAssertEqual(ReadinessLevel.from(percentage: 60), .intermediate)
        XCTAssertEqual(ReadinessLevel.from(percentage: 74), .intermediate)
    }
    
    func test_fromPercentage_advanced() {
        XCTAssertEqual(ReadinessLevel.from(percentage: 75), .advanced)
        XCTAssertEqual(ReadinessLevel.from(percentage: 80), .advanced)
        XCTAssertEqual(ReadinessLevel.from(percentage: 89), .advanced)
    }
    
    func test_fromPercentage_expert() {
        XCTAssertEqual(ReadinessLevel.from(percentage: 90), .expert)
        XCTAssertEqual(ReadinessLevel.from(percentage: 95), .expert)
        XCTAssertEqual(ReadinessLevel.from(percentage: 100), .expert)
    }
    
    // MARK: - displayName (Localization)
    
    func test_displayName_returnsLocalizedString() {
        let bundle = Bundle(for: type(of: self))
        NSLocalizedString("readiness.level.beginner", bundle: bundle, comment: "")
        
        XCTAssertEqual(ReadinessLevel.beginner.displayName, "Anfänger")  // German
        XCTAssertEqual(ReadinessLevel.expert.displayName, "Experte")
    }
    
    // MARK: - Comparison
    
    func test_readinessLevel_comparison() {
        XCTAssertTrue(ReadinessLevel.beginner < ReadinessLevel.intermediate)
        XCTAssertTrue(ReadinessLevel.intermediate < ReadinessLevel.advanced)
        XCTAssertTrue(ReadinessLevel.advanced < ReadinessLevel.expert)
        XCTAssertFalse(ReadinessLevel.expert < ReadinessLevel.beginner)
    }
    
    // MARK: - Codable
    
    func test_readinessLevel_encodable() throws {
        let level = ReadinessLevel.advanced
        let encoded = try JSONEncoder().encode(level)
        let decoded = try JSONDecoder().decode(ReadinessLevel.self, from: encoded)
        
        XCTAssertEqual(level, decoded)
    }
}