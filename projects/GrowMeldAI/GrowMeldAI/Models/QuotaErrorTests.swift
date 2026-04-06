// Tests/Freemium/Models/QuotaErrorTests.swift

import XCTest
@testable import DriveAI

class QuotaErrorTests: XCTestCase {
    
    func test_quotaExhausted_hasLocalizedError() {
        let error = QuotaError.quotaExhausted
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Tägeslimit") ?? false)
    }
    
    func test_trialExpired_hasRecoverySuggestion() {
        let error = QuotaError.trialExpired
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("Premium") ?? false)
    }
    
    func test_persistenceFailed_includesReason() {
        let error = QuotaError.persistenceFailed("Write permission denied")
        XCTAssertTrue(error.errorDescription?.contains("Write permission denied") ?? false)
    }
    
    func test_invalidState_includesDescription() {
        let error = QuotaError.invalidState("Unknown state variant")
        XCTAssertTrue(error.errorDescription?.contains("Unknown state variant") ?? false)
    }
    
    func test_equatable_sameError_equal() {
        let error1 = QuotaError.quotaExhausted
        let error2 = QuotaError.quotaExhausted
        XCTAssertEqual(error1, error2)
    }
    
    func test_equatable_differentErrors_notEqual() {
        let error1 = QuotaError.quotaExhausted
        let error2 = QuotaError.trialExpired
        XCTAssertNotEqual(error1, error2)
    }
}