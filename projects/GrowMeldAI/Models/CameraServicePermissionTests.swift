// Tests/Unit/Services/CameraServiceTests.swift
import XCTest
@testable import DriveAI

@MainActor
final class CameraServicePermissionTests: XCTestCase {
    var sut: CameraService!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        sut = CameraService(logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Permission Request (Happy Path)
    
    func test_requestPermissionAndStart_whenAlreadyAuthorized_startsSession() async {
        // Arrange
        let mockSession = MockAVCaptureSession()
        sut.captureSession = mockSession
        
        // Mock permission as already authorized
        AVCaptureDevice.setAuthorizationStatusOverride(.authorized, for: .video)
        
        // Act
        await sut.requestPermissionAndStart()
        
        // Assert
        XCTAssertTrue(sut.hasPermission)
        XCTAssertEqual(sut.state, .idle)
        XCTAssertTrue(mockSession.wasStartCalled)
    }
    
    func test_requestPermissionAndStart_whenNotDetermined_requestsAndProcesses() async {
        // Arrange
        AVCaptureDevice.setAuthorizationStatusOverride(.notDetermined, for: .video)
        
        let mockSession = MockAVCaptureSession()
        sut.captureSession = mockSession
        
        // Act
        await sut.requestPermissionAndStart()
        
        // Assert - depends on user response in mock
        XCTAssertTrue(AVCaptureDevice.requestAccessWasCalled(for: .video))
    }
    
    func test_requestPermissionAndStart_whenDenied_setsErrorState() async {
        // Arrange
        AVCaptureDevice.setAuthorizationStatusOverride(.denied, for: .video)
        
        // Act
        await sut.requestPermissionAndStart()
        
        // Assert
        XCTAssertFalse(sut.hasPermission)
        XCTAssertEqual(sut.state, .error(.permissionDenied))
        XCTAssertTrue(mockLogger.containsMessage("Camera permission denied"))
    }
    
    func test_requestPermissionAndStart_whenRestricted_setsErrorState() async {
        // Arrange
        AVCaptureDevice.setAuthorizationStatusOverride(.restricted, for: .video)
        
        // Act
        await sut.requestPermissionAndStart()
        
        // Assert
        XCTAssertFalse(sut.hasPermission)
        XCTAssertEqual(sut.state, .error(.permissionDenied))
    }
    
    // MARK: - Permission Edge Cases
    
    func test_startSession_withoutPermission_failsGracefully() async {
        // Arrange
        sut.hasPermission = false
        
        // Act
        await sut.startSession()
        
        // Assert
        XCTAssertEqual(sut.state, .error(.permissionDenied))
    }
    
    func test_requestPermissionAndStart_multipleTimes_doesNotDuplicateRequests() async {
        // Arrange
        AVCaptureDevice.setAuthorizationStatusOverride(.authorized, for: .video)
        
        // Act
        await sut.requestPermissionAndStart()
        await sut.requestPermissionAndStart()
        
        // Assert
        XCTAssertEqual(AVCaptureDevice.requestAccessCallCount(for: .video), 1)
    }
}

// MARK: - Test Suite: Session Management

@MainActor
final class CameraServiceSessionTests: XCTestCase {
    var sut: CameraService!
    var mockSession: MockAVCaptureSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockAVCaptureSession()
        sut = CameraService()
        sut.captureSession = mockSession
        sut.hasPermission = true
    }
    
    // MARK: - Session Lifecycle
    
    func test_startSession_startsUnderlyingSession() async {
        // Act
        await sut.startSession()
        
        // Assert
        XCTAssertTrue(mockSession.wasStartCalled)
        XCTAssertTrue(mockSession.isRunning)
    }
    
    func test_stopSession_stopsUnderlyingSession() async {
        // Arrange
        await sut.startSession()
        XCTAssertTrue(mockSession.isRunning)
        
        // Act
        await sut.stopSession()
        
        // Assert
        XCTAssertTrue(mockSession.wasStopCalled)
        XCTAssertFalse(mockSession.isRunning)
    }
    
    func test_startSession_whenAlreadyRunning_doesNotRestartDoubled() async {
        // Arrange
        mockSession.isRunning = true
        
        // Act
        await sut.startSession()
        await sut.startSession()
        
        // Assert
        XCTAssertEqual(mockSession.startCallCount, 1)
    }
    
    func test_stopSession_whenNotRunning_handlesGracefully() async {
        // Arrange
        mockSession.isRunning = false
        
        // Act
        await sut.stopSession()  // Should not crash
        
        // Assert - no exception
        XCTAssertTrue(true)
    }
    
    // MARK: - Concurrent Access
    
    func test_startAndStopSession_concurrently_maintainsConsistency() async {
        // Act
        async let start = sut.startSession()
        async let stop = sut.stopSession()
        
        let _ = await (start, stop)
        
        // Assert - final state should be consistent
        // (either running or stopped, not corrupted)
        XCTAssertTrue(mockSession.isInConsistentState == false)
    }
    
    func test_multipleCallsToStartSession_queuedSequentially() async {
        // Act
        await sut.startSession()
        await sut.startSession()
        await sut.startSession()
        
        // Assert
        XCTAssertEqual(mockSession.startCallCount, 1)  // Only called once due to guard
    }
}

// MARK: - Test Suite: Photo Capture

@MainActor
final class CameraServicePhotoCaptureTests: XCTestCase {
    var sut: CameraService!
    var mockPhotoOutput: MockAVCapturePhotoOutput!
    
    override func setUp() {
        super.setUp()
        mockPhotoOutput = MockAVCapturePhotoOutput()
        sut = CameraService()
        sut.photoOutput = mockPhotoOutput
    }
    
    // MARK: - Capture State Transitions
    
    func test_capturePhoto_withIdleState_transitionsToCapturing() async {
        // Arrange
        XCTAssertEqual(sut.state, .idle)
        
        // Act
        await sut.capturePhoto()
        
        // Assert
        XCTAssertEqual(sut.state, .capturing)
    }
    
    func test_capturePhoto_whenProcessing_refusesCapture() async {
        // Arrange
        sut.state = .processing()
        
        // Act
        await sut.capturePhoto()
        
        // Assert
        XCTAssertEqual(sut.state, .processing())  // State unchanged
        XCTAssertFalse(mockPhotoOutput.wasCapturePhotoCalled)
    }
    
    func test_capturePhoto_whenInError_allowsRetry() async {
        // Arrange
        sut.state = .error(.processingFailed("test"))
        
        // Act
        await sut.capturePhoto()
        
        // Assert
        XCTAssertEqual(sut.state, .capturing)
    }
    
    func test_capturePhoto_withoutPhotoOutput_failsGracefully() async {
        // Arrange
        sut.photoOutput = nil
        
        // Act
        await sut.capturePhoto()
        
        // Assert
        XCTAssertEqual(sut.state, .error(.processingFailed("Photo output not configured")))
    }
    
    // MARK: - Photo Delegate Lifecycle
    
    func test_capturePhoto_createsActiveDelegateRetained() async {
        // Arrange
        let initialDelegateCount = sut.activeDelegates.count
        
        // Act
        await sut.capturePhoto()
        
        // Assert
        XCTAssertEqual(sut.activeDelegates.count, initialDelegateCount + 1)
    }
    
    func test_photoDelegate_onSuccess_processesCIImage() async {
        // Arrange
        let testImage = CIImage(cgImage: UIImage(named: "testPlant")!.cgImage!)
        
        // Create delegate directly
        let expectation = XCTestExpectation(description: "Photo processed")
        let delegate = PhotoCaptureDelegate(id: UUID()) { result in
            if case .success(let image) = result {
                // Verify we can use the image
                XCTAssertNotNil(image)
                expectation.fulfill()
            }
        }
        
        // Act
        delegate.photoOutput(mockPhotoOutput, 
                            didFinishProcessingPhoto: MockAVCapturePhoto(pixelBuffer: testImage.pixelBuffer),
                            error: nil)
        
        // Assert
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func test_photoDelegate_onError_returnsFailure() async {
        // Arrange
        let testError = NSError(domain: "test", code: -1)
        
        let expectation = XCTestExpectation(description: "Error handled")
        let delegate = PhotoCaptureDelegate(id: UUID()) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, testError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        // Act
        delegate.photoOutput(mockPhotoOutput,
                            didFinishProcessingPhoto: MockAVCapturePhoto(pixelBuffer: nil),
                            error: testError)
        
        // Assert
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func test_photoDelegate_withNoPixelBuffer_failsGracefully() async {
        // Arrange
        let expectation = XCTestExpectation(description: "No buffer handled")
        let delegate = PhotoCaptureDelegate(id: UUID()) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error, .processingFailed("No pixel buffer captured"))
                expectation.fulfill()
            }
        }
        
        // Act
        delegate.photoOutput(mockPhotoOutput,
                            didFinishProcessingPhoto: MockAVCapturePhoto(pixelBuffer: nil),
                            error: nil)
        
        // Assert
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}

// MARK: - Test Suite: State Machine Validation

@MainActor
final class CameraStateValidationTests: XCTestCase {
    func test_canCapture_allowsIdleAndError() {
        XCTAssertTrue(CameraState.idle.canCapture)
        XCTAssertTrue(CameraState.error(.noPlantDetected).canCapture)
        XCTAssertFalse(CameraState.capturing.canCapture)
        XCTAssertFalse(CameraState.processing().canCapture)
    }
    
    func test_canSave_onlyAllowsSuccess() {
        XCTAssertTrue(CameraState.success(PlantIdentity.mock).canSave)
        XCTAssertFalse(CameraState.idle.canSave)
        XCTAssertFalse(CameraState.error(.noPlantDetected).canSave)
    }
    
    func test_canReset_allowsErrorAndSuccess() {
        XCTAssertTrue(CameraState.error(.noPlantDetected).canReset)
        XCTAssertTrue(CameraState.success(PlantIdentity.mock).canReset)
        XCTAssertFalse(CameraState.idle.canReset)
        XCTAssertFalse(CameraState.processing().canReset)
    }
    
    func test_isProcessing_identifiesActiveStates() {
        XCTAssertTrue(CameraState.capturing.isProcessing)
        XCTAssertTrue(CameraState.processing().isProcessing)
        XCTAssertTrue(CameraState.saving(PlantIdentity.mock).isProcessing)
        
        XCTAssertFalse(CameraState.idle.isProcessing)
        XCTAssertFalse(CameraState.error(.noPlantDetected).isProcessing)
    }
}