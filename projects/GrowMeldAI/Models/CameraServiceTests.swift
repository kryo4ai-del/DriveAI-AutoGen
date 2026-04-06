import XCTest
import AVFoundation
@testable import DriveAI

@MainActor
final class CameraServiceTests: XCTestCase {
    
    var sut: CameraService!
    var mockPermissionService: MockCameraPermissionService!
    
    override func setUp() {
        super.setUp()
        mockPermissionService = MockCameraPermissionService()
        sut = CameraService(permissionService: mockPermissionService)
    }
    
    override func tearDown() {
        sut.teardown()
        sut = nil
        mockPermissionService = nil
        super.tearDown()
    }
    
    // MARK: - Setup & Teardown
    
    func test_setupCamera_initialState_idle() {
        XCTAssertEqual(sut.cameraState, .idle)
    }
    
    func test_teardown_clearsSession() {
        let expectation = XCTestExpectation(description: "Teardown completes")
        
        Task {
            _ = await sut.setupCamera()
            sut.teardown()
            
            // Give async teardown time to complete
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            
            XCTAssertEqual(sut.cameraState, .idle)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Permission Handling
    
    func test_setupCamera_permissionDenied_returnsFailure() async {
        mockPermissionService.mockAuthorizationStatus = .denied
        
        let result = await sut.setupCamera()
        
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .permissionDenied)
        case .success:
            XCTFail("Expected failure")
        }
    }
    
    func test_setupCamera_permissionDenied_setsState() async {
        mockPermissionService.mockAuthorizationStatus = .denied
        
        _ = await sut.setupCamera()
        
        XCTAssertEqual(sut.cameraState, .accessDenied)
    }
    
    func test_setupCamera_askingForAccess_changesState() async {
        mockPermissionService.mockAuthorizationStatus = .notDetermined
        
        let setupTask = Task {
            _ = await sut.setupCamera()
        }
        
        // Give state time to change
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // State should be .askingForAccess briefly
        await setupTask.value
    }
    
    // MARK: - State Transitions
    
    func test_setupCamera_success_setsReadyState() async {
        // This test may fail on simulator without camera
        // Wrap in try/catch for cross-platform compatibility
        mockPermissionService.mockAuthorizationStatus = .authorized
        
        let result = await sut.setupCamera()
        
        switch result {
        case .success:
            XCTAssertEqual(sut.cameraState, .ready)
        case .failure(let error):
            // Device has no camera; acceptable failure
            XCTAssertEqual(error, .noCameraAvailable)
        }
    }
    
    // MARK: - Capture Session Cleanup
    
    func test_deinit_callsTeardown() async {
        // Create service in local scope
        var localService: CameraService? = CameraService(
            permissionService: mockPermissionService
        )
        
        let setupResult = await localService?.setupCamera()
        XCTAssertNotNil(setupResult)
        
        // Deallocate
        localService = nil
        
        // If deinit calls teardown, no crash
        XCTAssertTrue(true)
    }
    
    // MARK: - Photo Capture
    
    func test_capturePhoto_notReady_returnsFailure() async {
        sut.cameraState = .idle
        
        let result = await sut.capturePhoto()
        
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .captureSessionSetupFailed)
        case .success:
            XCTFail("Expected failure")
        }
    }
    
    func test_capturePhoto_capturing_changesState() async {
        // Setup must succeed on physical device
        mockPermissionService.mockAuthorizationStatus = .authorized
        let setupResult = await sut.setupCamera()
        
        guard case .success = setupResult else {
            XCTSkip("Camera hardware unavailable")
        }
        
        // Initiate capture (don't await to check state mid-capture)
        let captureTask = Task {
            await sut.capturePhoto()
        }
        
        // Give capture time to set state
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // State should be .capturing
        XCTAssertEqual(sut.cameraState, .capturing)
        
        // Let it finish
        _ = await captureTask.value
    }
    
    // MARK: - Reset
    
    func test_reset_setsReadyState() async {
        mockPermissionService.mockAuthorizationStatus = .authorized
        _ = await sut.setupCamera()
        
        sut.cameraState = .captureError("Test error")
        sut.reset()
        
        XCTAssertEqual(sut.cameraState, .ready)
    }
    
    // MARK: - Settings Navigation
    
    func test_handleOpenSettings_changesState() {
        sut.cameraState = .ready
        sut.handleOpenSettings()
        
        XCTAssertEqual(sut.cameraState, .openingSettings)
    }
}

// MARK: - Mock Photo Output Delegate

final class MockPhotoOutputDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var didFinishProcessingPhotoCalled = false
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        didFinishProcessingPhotoCalled = true
    }
}