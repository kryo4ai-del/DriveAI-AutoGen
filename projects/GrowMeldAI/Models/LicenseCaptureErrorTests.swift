import XCTest
@testable import DriveAI

final class LicenseCaptureErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    
    func test_permissionDeniedError_returnsCorrectDescription() {
        let error = LicenseCaptureError.permissionDenied
        XCTAssertEqual(
            error.errorDescription,
            "Kamerazugriff erforderlich"
        )
    }
    
    func test_poorQualityError_includQualityScore() {
        let error = LicenseCaptureError.poorQuality(score: 0.45)
        XCTAssertTrue(error.errorDescription?.contains("45%") ?? false)
    }
    
    func test_storageFailureError_includesReason() {
        let reason = "Disk full"
        let error = LicenseCaptureError.storageFailure(reason: reason)
        XCTAssertTrue(error.errorDescription?.contains(reason) ?? false)
    }
    
    // MARK: - Recovery Suggestion Tests
    
    func test_permissionDeniedError_providesRecoverySuggestion() {
        let error = LicenseCaptureError.permissionDenied
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("Einstellungen") ?? false)
    }
    
    func test_poorQualityError_providesFeedback() {
        let error = LicenseCaptureError.poorQuality(score: 0.5)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    // MARK: - Equatable Conformance
    
    func test_sameErrorTypes_areEqual() {
        let error1 = LicenseCaptureError.permissionDenied
        let error2 = LicenseCaptureError.permissionDenied
        XCTAssertEqual(error1, error2)
    }
    
    func test_differentErrorTypes_areNotEqual() {
        let error1 = LicenseCaptureError.permissionDenied
        let error2 = LicenseCaptureError.cameraUnavailable
        XCTAssertNotEqual(error1, error2)
    }
    
    func test_qualityErrorsWithDifferentScores_areNotEqual() {
        let error1 = LicenseCaptureError.poorQuality(score: 0.5)
        let error2 = LicenseCaptureError.poorQuality(score: 0.6)
        XCTAssertNotEqual(error1, error2)
    }
}