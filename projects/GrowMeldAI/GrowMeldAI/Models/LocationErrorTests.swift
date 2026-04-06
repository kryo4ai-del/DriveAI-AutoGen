@MainActor
final class LocationErrorTests: XCTestCase {
    
    // MARK: - Equality & Hashable
    
    func testErrorEquality() {
        let error1 = LocationError.plzNotFound("10115")
        let error2 = LocationError.plzNotFound("10115")
        let error3 = LocationError.plzNotFound("80331")
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    func testErrorHashable() {
        let error1 = LocationError.invalidFormat("invalid")
        let error2 = LocationError.invalidFormat("invalid")
        let error3 = LocationError.databaseError("msg")
        
        var set = Set<LocationError>()
        set.insert(error1)
        set.insert(error2)  // Same error, no duplicate
        set.insert(error3)
        
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - LocalizedError Protocol
    
    func testErrorDescriptions() {
        let invalidError = LocationError.invalidFormat("12345")
        XCTAssertTrue(invalidError.errorDescription?.contains("5 Ziffern") ?? false)
        
        let notFoundError = LocationError.plzNotFound("99999")
        XCTAssertTrue(notFoundError.errorDescription?.contains("99999") ?? false)
        
        let offlineError = LocationError.offlineUnavailable
        XCTAssertTrue(offlineError.errorDescription?.contains("Datenbank") ?? false)
    }
    
    func testRecoverySuggestions() {
        let error = LocationError.invalidFormat("abc")
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion!.contains("5-stellige"))
    }
    
    // MARK: - Sendable Conformance
    
    func testErrorSendable() async {
        let error = LocationError.plzNotFound("12345")
        let errorCopy = await Task { @Sendable () -> LocationError in
            error
        }.value
        
        XCTAssertEqual(error, errorCopy)
    }
}