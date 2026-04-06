import XCTest
@testable import DriveAI

final class CameraStateTests: XCTestCase {
    
    // MARK: - State Equatable Conformance
    
    func test_cameraState_idle_equatable() {
        XCTAssertEqual(CameraState.idle, CameraState.idle)
    }
    
    func test_cameraState_different_states_notEqual() {
        XCTAssertNotEqual(CameraState.idle, CameraState.ready)
        XCTAssertNotEqual(CameraState.capturing, CameraState.ready)
    }
    
    func test_cameraState_photoReady_equatable() {
        let image = UIImage(systemName: "camera")!
        XCTAssertEqual(
            CameraState.photoReady(image),
            CameraState.photoReady(image)
        )
    }
    
    func test_cameraState_photoReady_differentImages_notEqual() {
        let image1 = UIImage(systemName: "camera")!
        let image2 = UIImage(systemName: "photo")!
        XCTAssertNotEqual(
            CameraState.photoReady(image1),
            CameraState.photoReady(image2)
        )
    }
    
    func test_cameraState_captureError_equatable() {
        XCTAssertEqual(
            CameraState.captureError("Test error"),
            CameraState.captureError("Test error")
        )
    }
    
    func test_cameraState_captureError_differentMessages_notEqual() {
        XCTAssertNotEqual(
            CameraState.captureError("Error 1"),
            CameraState.captureError("Error 2")
        )
    }
    
    // MARK: - State Transitions
    
    func test_cameraState_transitionSequence_happy() {
        var state: CameraState = .idle
        
        state = .askingForAccess
        XCTAssertEqual(state, .askingForAccess)
        
        state = .ready
        XCTAssertEqual(state, .ready)
        
        state = .capturing
        XCTAssertEqual(state, .capturing)
        
        state = .photoReady(UIImage(systemName: "camera")!)
        guard case .photoReady = state else {
            XCTFail("Expected photoReady state")
            return
        }
    }
}

final class CameraErrorTests: XCTestCase {
    
    // MARK: - Error Localization
    
    func test_cameraError_noCameraAvailable_localized() {
        let error = CameraError.noCameraAvailable
        XCTAssertNotNil(error.errorDescription)
        XCTAssert(error.errorDescription?.isEmpty == false)
        XCTAssertTrue(error.errorDescription!.contains("Kamera"))
    }
    
    func test_cameraError_permissionDenied_localized() {
        let error = CameraError.permissionDenied
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssert(error.recoverySuggestion?.isEmpty == false)
    }
    
    func test_cameraError_unknown_localized() {
        let error = CameraError.unknown("Custom message")
        XCTAssertNotNil(error.errorDescription)
        // Should NOT contain custom message; should be generic
        XCTAssertTrue(error.errorDescription!.contains("unbekannten"))
    }
    
    // MARK: - Error Equatable Conformance
    
    func test_cameraError_equatable() {
        XCTAssertEqual(CameraError.noCameraAvailable, CameraError.noCameraAvailable)
        XCTAssertEqual(CameraError.permissionDenied, CameraError.permissionDenied)
    }
    
    func test_cameraError_unknown_equatable() {
        XCTAssertEqual(
            CameraError.unknown("Test"),
            CameraError.unknown("Test")
        )
    }
    
    func test_cameraError_different_types_notEqual() {
        XCTAssertNotEqual(
            CameraError.noCameraAvailable,
            CameraError.permissionDenied
        )
    }
}

final class PhotoCaptureTests: XCTestCase {
    
    // MARK: - Initialization
    
    func test_photoCapture_init_setsID() {
        let image = UIImage(systemName: "camera")!
        let photo = PhotoCapture(image: image)
        
        XCTAssertNotEqual(photo.id, UUID())
    }
    
    func test_photoCapture_init_setsTimestamp() {
        let image = UIImage(systemName: "camera")!
        let beforeInit = Date()
        let photo = PhotoCapture(image: image)
        let afterInit = Date()
        
        XCTAssertGreaterThanOrEqual(photo.timestamp, beforeInit)
        XCTAssertLessThanOrEqual(photo.timestamp, afterInit)
    }
    
    func test_photoCapture_init_calculatesFileSize() {
        let image = UIImage(systemName: "camera")!
        let photo = PhotoCapture(image: image)
        
        XCTAssertGreaterThan(photo.fileSize, 0)
    }
    
    func test_photoCapture_init_customTimestamp() {
        let image = UIImage(systemName: "camera")!
        let customDate = Date(timeIntervalSince1970: 0)
        let photo = PhotoCapture(image: image, timestamp: customDate)
        
        XCTAssertEqual(photo.timestamp, customDate)
    }
    
    // MARK: - Identifiable
    
    func test_photoCapture_identifiable_uniqueIDs() {
        let image = UIImage(systemName: "camera")!
        let photo1 = PhotoCapture(image: image)
        let photo2 = PhotoCapture(image: image)
        
        XCTAssertNotEqual(photo1.id, photo2.id)
    }
}