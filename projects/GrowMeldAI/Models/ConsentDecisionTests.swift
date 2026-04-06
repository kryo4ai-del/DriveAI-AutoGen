final class ConsentDecisionTests: XCTestCase {
    
    // TC-001: Create consent decision with success
    func testInit_validInput_createsDecision() {
        let decision = ConsentDecision(userConsented: true)
        
        XCTAssertTrue(decision.userConsented)
        XCTAssertEqual(decision.version, 1)
        XCTAssertLessThanOrEqual(
            Date().timeIntervalSince(decision.timestamp),
            0.1  // Created within 100ms
        )
    }
    
    // TC-002: Create consent decision with custom timestamp
    func testInit_customTimestamp_preservesValue() {
        let customDate = Date(timeIntervalSince1970: 1640000000)
        let decision = ConsentDecision(userConsented: false, timestamp: customDate)
        
        XCTAssertEqual(decision.timestamp, customDate)
        XCTAssertFalse(decision.userConsented)
    }
    
    // TC-003: Encode to JSON (ISO8601 date format)
    func testEncode_iso8601_successfullyEncodes() throws {
        let decision = ConsentDecision(userConsented: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(decision)
        
        XCTAssertFalse(data.isEmpty)
        let jsonString = String(data: data, encoding: .utf8)!
        XCTAssertTrue(jsonString.contains("\"userConsented\":true"))
        XCTAssertTrue(jsonString.contains("\"version\":1"))
    }
}