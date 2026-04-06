import XCTest
@testable import DriveAI

final class AppErrorTests: XCTestCase {
    
    // MARK: - LocalizedError Conformance
    
    func test_networkUnavailable_hasErrorDescription() {
        let error = DriveAIError.networkUnavailable
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Netzwerk") ?? false)
    }
    
    func test_networkTimeout_includesSeconds() {
        let error = DriveAIError.networkTimeout(timeoutSeconds: 10.5)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("10") ?? false)
    }
    
    func test_firestoreError_translatesKnownCodes() {
        let error = DriveAIError.firestoreError(code: "NOT_FOUND", underlying: "test")
        let desc = error.errorDescription ?? ""
        XCTAssertTrue(desc.contains("Fehler") || desc.contains("nicht"))
    }
    
    func test_documentNotFound_includesDocumentId() {
        let error = DriveAIError.documentNotFound(id: "test-doc-123")
        let desc = error.errorDescription ?? ""
        XCTAssertTrue(desc.contains("test-doc-123"))
    }
    
    func test_error_hasRecoverySuggestion() {
        let error = DriveAIError.networkUnavailable
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertFalse(error.recoverySuggestion?.isEmpty ?? true)
    }
    
    // MARK: - Equatable Conformance
    
    func test_identicalErrors_areEqual() {
        let error1 = DriveAIError.networkUnavailable
        let error2 = DriveAIError.networkUnavailable
        XCTAssertEqual(error1, error2)
    }
    
    func test_differentErrors_areNotEqual() {
        let error1 = DriveAIError.networkUnavailable
        let error2 = DriveAIError.authenticationFailed
        XCTAssertNotEqual(error1, error2)
    }
    
    func test_parametrizedErrors_equalIfParametersMatch() {
        let error1 = DriveAIError.documentNotFound(id: "doc1")
        let error2 = DriveAIError.documentNotFound(id: "doc1")
        XCTAssertEqual(error1, error2)
    }
    
    func test_parametrizedErrors_unequalIfParametersDiffer() {
        let error1 = DriveAIError.documentNotFound(id: "doc1")
        let error2 = DriveAIError.documentNotFound(id: "doc2")
        XCTAssertNotEqual(error1, error2)
    }
    
    // MARK: - Hashable Conformance
    
    func test_error_canBeStoredInSet() {
        let error1 = DriveAIError.networkUnavailable
        let error2 = DriveAIError.authenticationFailed
        var errorSet: Set<DriveAIError> = [error1, error2]
        XCTAssertEqual(errorSet.count, 2)
        XCTAssertTrue(errorSet.contains(error1))
    }
    
    func test_error_canBeUsedAsDictionaryKey() {
        let error = DriveAIError.networkUnavailable
        var errorMap: [DriveAIError: String] = [:]
        errorMap[error] = "Network error"
        XCTAssertEqual(errorMap[error], "Network error")
    }
    
    // MARK: - Factory Methods
    
    func test_fromFirestoreError_convertsNSError() {
        let nsError = NSError(
            domain: "FIRFirestoreErrorDomain",
            code: 5,
            userInfo: [NSLocalizedDescriptionKey: "Test error"]
        )
        let driveAIError = DriveAIError.from(firestoreError: nsError)
        
        if case .firestoreError(_, _) = driveAIError {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected firestoreError case")
        }
    }
    
    func test_decodingError_truncatesLongValues() {
        let longValue = String(repeating: "x", count: 100)
        let error = DriveAIError.decodingError(type: "Question", value: longValue)
        
        if case .dataDecodingFailed(_, let value) = error {
            XCTAssertLessThanOrEqual(value.count, 50)
        } else {
            XCTFail("Expected dataDecodingFailed case")
        }
    }
    
    #if DEBUG
    func test_testError_onlyAvailableInDebug() {
        let error = DriveAIError.testError(message: "test")
        XCTAssertNotNil(error.errorDescription?.contains("[TEST]"))
    }
    #endif
    
    // MARK: - Sendable Conformance
    
    func test_error_isSendable() {
        let error = DriveAIError.networkUnavailable
        Task {
            let _ = error  // Should compile with strict Sendable checking
        }
    }
}