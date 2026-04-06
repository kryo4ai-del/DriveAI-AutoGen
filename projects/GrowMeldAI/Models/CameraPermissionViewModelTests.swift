// Features/Camera/Tests/CameraPermissionViewModelTests.swift
import XCTest
import Combine
@testable import DriveAI

@MainActor
final class CameraPermissionViewModelTests: XCTestCase {
    
    var sut: CameraPermissionViewModel!
    var mockManager: MockCameraAccessManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockManager = MockCameraAccessManager()
        sut = CameraPermissionViewModel(cameraManager: mockManager)
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockManager = nil
        cancellables = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInit_ChecksPermissionStatus() {
        // Given: Fresh ViewModel instance
        mockManager.mockStatus = .denied
        let vm = CameraPermissionViewModel(cameraManager: mockManager)
        
        // When: ViewModel initializes
        // Then: Should check initial permission status
        XCTAssertEqual(mockManager.checkCameraPermissionCallCount, 1)
        XCTAssertEqual(vm.status, .denied)
    }
    
    func testInit_WithAuthorizedStatus_SetsCameraAccessible() {
        // Given: Camera already authorized
        mockManager.mockStatus = .authorized
        let vm = CameraPermissionViewModel(cameraManager: mockManager)
        
        // When: ViewModel initializes
        // Then: canAccessCamera should be true
        XCTAssertTrue(vm.canAccessCamera)
    }
    
    // MARK: - requestCameraAccess() Tests
    
    func testRequestCameraAccess_WhenNotDetermined_RequestsPermission() async {
        // Given: Permission not yet determined
        mockManager.mockStatus = .notDetermined
        sut.checkInitialPermission()
        XCTAssertEqual(sut.status, .notDetermined)
        
        // When: Requesting permission
        mockManager.mockStatus = .authorized
        await sut.requestCameraAccess()
        
        // Then: Should call cameraManager.requestCameraPermission()
        XCTAssertEqual(mockManager.requestCameraPermissionCallCount, 1)
    }
    
    func testRequestCameraAccess_WhenGranted_SetsCanAccessCameraTrue() async {
        // Given: Permission request succeeds
        mockManager.mockStatus = .notDetermined
        sut.checkInitialPermission()
        mockManager.mockStatus = .authorized
        
        // When: User grants permission
        await sut.requestCameraAccess()
        
        // Then: canAccessCamera should be true
        XCTAssertTrue(sut.canAccessCamera)
        XCTAssertNil(sut.error)
    }
    
    func testRequestCameraAccess_WhenDenied_ShowsSettingsAlert() async {
        // Given: User denies permission
        mockManager.mockStatus = .notDetermined
        sut.checkInitialPermission()
        mockManager.mockStatus = .denied
        
        // When: Requesting permission
        await sut.requestCameraAccess()
        
        // Then: Should show settings alert
        XCTAssertTrue(sut.showSettingsAlert)
        XCTAssertEqual(sut.error, .permissionDenied)
        XCTAssertTrue(sut.isDenied)
    }
    
    func testRequestCameraAccess_WhenRestricted_SetIsRestricted() async {
        // Given: Camera access is restricted (parental controls)
        mockManager.mockStatus = .notDetermined
        sut.checkInitialPermission()
        mockManager.mockStatus = .restricted
        
        // When: Requesting permission
        await sut.requestCameraAccess()
        
        // Then: Should set restricted flag
        XCTAssertTrue(sut.isRestricted)
        XCTAssertEqual(sut.error, .permissionRestricted)
    }
    
    func testRequestCameraAccess_WhenAlreadyDetermined_SkipsRequest() async {
        // Given: Permission already determined
        mockManager.mockStatus = .authorized
        sut.checkInitialPermission()
        let initialCallCount = mockManager.requestCameraPermissionCallCount
        
        // When: Calling requestCameraAccess again
        await sut.requestCameraAccess()
        
        // Then: Should not make another request
        XCTAssertEqual(
            mockManager.requestCameraPermissionCallCount,
            initialCallCount,
            "Should skip request if already determined"
        )
    }
    
    func testRequestCameraAccess_SetsIsLoadingDuringRequest() async {
        // Given: Permission not determined
        mockManager.mockStatus = .notDetermined
        sut.checkInitialPermission()
        
        // When: Requesting permission
        let loadingStates = NSMutableArray()
        sut.$isLoading
            .sink { loadingStates.add($0) }
            .store(in: &cancellables)
        
        await sut.requestCameraAccess()
        
        // Then: isLoading should toggle true then false
        XCTAssertTrue(
            loadingStates.count >= 2,
            "isLoading should emit at least 2 values (true, false)"
        )
    }
    
    // MARK: - openSettings() Tests
    
    func testOpenSettings_CallsCameraManagerOpenAppSettings() {
        // Given: Need to open settings
        // When: Calling openSettings
        sut.openSettings()
        
        // Then: Should call manager's openAppSettings()
        XCTAssertEqual(mockManager.openAppSettingsCallCount, 1)
    }
    
    // MARK: - State Properties Tests
    
    func testCanAccessCamera_ReturnsTrueOnlyWhenAuthorized() {
        // Given: Various permission states
        let testCases: [(CameraPermissionStatus, Bool)] = [
            (.notDetermined, false),
            (.authorized, true),
            (.denied, false),
            (.restricted, false),
            (.unavailable, false),
        ]
        
        testCases.forEach { status, expectedAccessible in
            mockManager.mockStatus = status
            let vm = CameraPermissionViewModel(cameraManager: mockManager)
            
            // When: Checking canAccessCamera
            // Then: Should only be true for .authorized
            XCTAssertEqual(
                vm.canAccessCamera,
                expectedAccessible,
                "canAccessCamera incorrect for status: \(status)"
            )
        }
    }
    
    func testIsDenied_ReturnsTrueOnlyWhenDenied() {
        // Given: Permission is denied
        mockManager.mockStatus = .denied
        let vm = CameraPermissionViewModel(cameraManager: mockManager)
        
        // When: Checking isDenied
        // Then: Should be true
        XCTAssertTrue(vm.isDenied)
    }
    
    // MARK: - Error Handling Tests
    
    func testError_NilWhenAuthorized() {
        // Given: Permission granted
        mockManager.mockStatus = .authorized
        let vm = CameraPermissionViewModel(cameraManager: mockManager)
        
        // When: Status is authorized
        // Then: error should be nil
        XCTAssertNil(vm.error)
    }
    
    func testAlertMessage_MatchesErrorRecoverySuggestion() async {
        // Given: Permission denied
        mockManager.mockStatus = .notDetermined
        sut.checkInitialPermission()
        mockManager.mockStatus = .denied
        await sut.requestCameraAccess()
        
        // When: Checking alert message
        // Then: Should contain recovery suggestion
        XCTAssertTrue(
            sut.alertMessage.contains("Einstellungen"),
            "Alert message should suggest opening settings"
        )
    }
    
    // MARK: - External State Changes Tests
    
    func testCheckInitialPermission_UpdatesStatusFromManager() {
        // Given: ViewModel with specific initial permission
        mockManager.mockStatus = .denied
        sut.checkInitialPermission()
        XCTAssertEqual(sut.status, .denied)
        
        // When: Permission status changes externally (e.g., in Settings app)
        mockManager.mockStatus = .authorized
        sut.checkInitialPermission()
        
        // Then: ViewModel status should refresh
        XCTAssertEqual(sut.status, .authorized)
    }
}