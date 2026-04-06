// Tests/Services/Errors/PurchaseErrorTests.swift

import XCTest
@testable import DriveAI

final class PurchaseErrorTests: XCTestCase {
    
    // MARK: - Localization Tests
    
    func test_storageNotAvailable_hasGermanErrorDescription() {
        let error = PurchaseError.storageNotAvailable
        XCTAssertEqual(
            error.errorDescription,
            NSLocalizedString("Speicher nicht verfügbar", comment: "Storage unavailable")
        )
    }
    
    func test_corruptedData_hasRecoverySuggestion() {
        let underlying = NSError(domain: "test", code: 1)
        let error = PurchaseError.corruptedData(underlying: underlying)
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("schließen") ?? false)
    }
    
    func test_verificationFailed_includingContactInfo() {
        let error = PurchaseError.verificationFailed
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("support") ?? false)
    }
    
    func test_allCases_haveErrorDescriptions() {
        let errors: [PurchaseError] = [
            .storageNotAvailable,
            .corruptedData(underlying: NSError(domain: "", code: 0)),
            .verificationFailed,
            .insufficientPermissions,
            .fileNotFound,
            .encodeFailure(underlying: NSError(domain: "", code: 0)),
            .networkError(underlying: NSError(domain: "", code: 0)),
            .productNotFound,
            .purchaseCancelled,
            .unknown
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error \(error) missing description")
        }
    }
    
    // MARK: - Sendable Conformance
    
    func test_purchaseError_isSendable() {
        let error: PurchaseError = .productNotFound
        Task {
            // Compile-time check that PurchaseError conforms to Sendable
            let _ = error
        }
    }
}