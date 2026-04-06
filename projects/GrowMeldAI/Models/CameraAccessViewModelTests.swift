@MainActor
class CameraAccessViewModelTests: XCTestCase {
    var sut: CameraAccessViewModel!
    var mockManager: MockCameraAccessManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockManager = MockCameraAccessManager()
        sut = CameraAccessViewModel(cameraManager: mockManager)
        cancellables = []
    }
    
    // ✅ Add @MainActor to EVERY async test
    @MainActor
    func test_initialUIState_showsPermissionRequest() {
        XCTAssertTrue(sut.showPermissionRequest)
    }
    
    @MainActor
    func test_requestPermission_setsLoadingState() async {
        // ... test body
    }
    
    @MainActor
    func test_requestPermission_completesWithSuccess_whenAuthorized() async {
        mockManager.permissionState = .authorized
        await sut.requestCameraPermission()
        XCTAssertTrue(sut.hasPermission)
    }
    
    // Apply to all async test methods...
}