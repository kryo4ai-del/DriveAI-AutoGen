import XCTest
@testable import DriveAI

final class PermissionFlowStateTests: XCTestCase {
    
    // MARK: - State Transition Validation
    
    func testInitialToRequestingPermissionTransition() {
        let initial = PermissionFlowState.initial
        let requesting = PermissionFlowState.requestingPermission
        
        XCTAssertTrue(initial.canTransitionTo(requesting),
                      "Should allow transition from initial to requestingPermission")
    }
    
    func testRequestingPermissionToGrantedTransition() {
        let requesting = PermissionFlowState.requestingPermission
        let granted = PermissionFlowState.permissionGranted
        
        XCTAssertTrue(requesting.canTransitionTo(granted),
                      "Should allow transition to permissionGranted after requesting")
    }
    
    func testRequestingPermissionToDeniedTransition() {
        let requesting = PermissionFlowState.requestingPermission
        let denied = PermissionFlowState.permissionDenied(reason: "User denied")
        
        XCTAssertTrue(requesting.canTransitionTo(denied),
                      "Should allow transition to permissionDenied after requesting")
    }
    
    func testPermissionGrantedToCapturingTransition() {
        let granted = PermissionFlowState.permissionGranted
        let capturing = PermissionFlowState.capturingPhoto
        
        XCTAssertTrue(granted.canTransitionTo(capturing),
                      "Should allow transition from permissionGranted to capturingPhoto")
    }
    
    func testPhotoReadyToPreviewingTransition() {
        let testData = "test".data(using: .utf8)!
        let photoReady = PermissionFlowState.photoReady(imageData: testData)
        let previewing = PermissionFlowState.previewingPhoto(imageData: testData)
        
        XCTAssertTrue(photoReady.canTransitionTo(previewing),
                      "Should allow transition from photoReady to previewingPhoto")
    }
    
    func testPreviewingToCompletedTransition() {
        let testData = "test".data(using: .utf8)!
        let previewing = PermissionFlowState.previewingPhoto(imageData: testData)
        let completed = PermissionFlowState.completed
        
        XCTAssertTrue(previewing.canTransitionTo(completed),
                      "Should allow transition from previewingPhoto to completed")
    }
    
    // MARK: - Invalid Transitions
    
    func testInitialToCompletedIsInvalid() {
        let initial = PermissionFlowState.initial
        let completed = PermissionFlowState.completed
        
        XCTAssertFalse(initial.canTransitionTo(completed),
                       "Should not allow direct transition from initial to completed")
    }
    
    func testCapturingToCompletedIsInvalid() {
        let capturing = PermissionFlowState.capturingPhoto
        let completed = PermissionFlowState.completed
        
        XCTAssertFalse(capturing.canTransitionTo(completed),
                       "Should not allow transition from capturingPhoto directly to completed")
    }
    
    func testPhotoDeniedToCapturingIsInvalid() {
        let denied = PermissionFlowState.permissionDenied(reason: "User denied")
        let capturing = PermissionFlowState.capturingPhoto
        
        XCTAssertFalse(denied.canTransitionTo(capturing),
                       "Should not allow transition from permissionDenied to capturingPhoto")
    }
    
    // MARK: - Error Transitions (Always Allowed)
    
    func testErrorTransitionFromAnyState() {
        let states: [PermissionFlowState] = [
            .initial,
            .requestingPermission,
            .permissionGranted,
            .capturingPhoto
        ]
        
        let error = PermissionFlowState.error(.cameraUnavailable)
        
        for state in states {
            XCTAssertTrue(state.canTransitionTo(error),
                          "Should allow error transition from \(state)")
        }
    }
    
    // MARK: - Reset Transitions
    
    func testResetFromAnyState() {
        let states: [PermissionFlowState] = [
            .initial,
            .permissionGranted,
            .capturingPhoto,
            .completed,
            .error(.cameraUnavailable)
        ]
        
        let initial = PermissionFlowState.initial
        
        for state in states {
            XCTAssertTrue(state.canTransitionTo(initial),
                          "Should allow reset to initial from \(state)")
        }
    }
    
    // MARK: - State Properties
    
    func testCanProceedToCaptureWhenPermissionGranted() {
        let granted = PermissionFlowState.permissionGranted
        
        XCTAssertTrue(granted.canProceedToCapture,
                      "Should allow proceed to capture when permission granted")
    }
    
    func testCannotProceedToCaptureWhenInitial() {
        let initial = PermissionFlowState.initial
        
        XCTAssertFalse(initial.canProceedToCapture,
                       "Should not allow proceed to capture when initial")
    }
    
    func testCanRetryWhenPermissionDenied() {
        let denied = PermissionFlowState.permissionDenied(reason: "User denied")
        
        XCTAssertTrue(denied.canRetry,
                      "Should allow retry when permission denied")
    }
    
    func testCanRetryWhenError() {
        let error = PermissionFlowState.error(.captureFailure("Camera not available"))
        
        XCTAssertTrue(error.canRetry,
                      "Should allow retry when in error state")
    }
    
    func testCannotRetryWhenCompleted() {
        let completed = PermissionFlowState.completed
        
        XCTAssertFalse(completed.canRetry,
                       "Should not allow retry when completed")
    }
    
    // MARK: - Step Numbers
    
    func testStepNumberProgression() {
        let steps: [(state: PermissionFlowState, expected: Int)] = [
            (.initial, 0),
            (.requestingPermission, 1),
            (.permissionGranted, 2),
            (.capturingPhoto, 3),
            (.photoReady(imageData: Data()), 4),
            (.previewingPhoto(imageData: Data()), 4),
            (.completed, 5)
        ]
        
        for (state, expected) in steps {
            XCTAssertEqual(state.stepNumber, expected,
                          "Step number mismatch for \(state)")
        }
    }
    
    // MARK: - Equatable Conformance
    
    func testStateEquality() {
        let initial1 = PermissionFlowState.initial
        let initial2 = PermissionFlowState.initial
        
        XCTAssertEqual(initial1, initial2,
                       "Identical states should be equal")
    }
    
    func testStateInequalityDifferentTypes() {
        let initial = PermissionFlowState.initial
        let requesting = PermissionFlowState.requestingPermission
        
        XCTAssertNotEqual(initial, requesting,
                         "Different states should not be equal")
    }
    
    func testPermissionDeniedEqualityWithSameReason() {
        let reason = "User denied access"
        let denied1 = PermissionFlowState.permissionDenied(reason: reason)
        let denied2 = PermissionFlowState.permissionDenied(reason: reason)
        
        XCTAssertEqual(denied1, denied2,
                       "Same reasons should be equal")
    }
    
    func testPermissionDeniedInequalityWithDifferentReasons() {
        let denied1 = PermissionFlowState.permissionDenied(reason: "User denied")
        let denied2 = PermissionFlowState.permissionDenied(reason: "Restricted")
        
        XCTAssertNotEqual(denied1, denied2,
                         "Different reasons should not be equal")
    }
}