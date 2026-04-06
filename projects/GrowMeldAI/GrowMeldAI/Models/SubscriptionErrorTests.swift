final class SubscriptionErrorTests: XCTestCase {
    
    func testErrorLocalizedDescriptions() {
        XCTAssertNotNil(SubscriptionError.productNotFound.errorDescription)
        XCTAssertNotNil(SubscriptionError.paymentCancelled.errorDescription)
        XCTAssertNotNil(SubscriptionError.networkError.errorDescription)
    }
    
    func testErrorDiagnosticCodes() {
        XCTAssertEqual(SubscriptionError.productNotFound.diagnosticCode, "SUB_001")
        XCTAssertEqual(SubscriptionError.paymentCancelled.diagnosticCode, "SUB_003")
        XCTAssertEqual(SubscriptionError.networkError.diagnosticCode, "SUB_005")
    }
    
    func testErrorCodable() throws {
        let error = SubscriptionError.paymentFailed(code: "DECLINE")
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(error)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SubscriptionError.self, from: encoded)
        
        XCTAssertEqual(decoded, error)
    }
}