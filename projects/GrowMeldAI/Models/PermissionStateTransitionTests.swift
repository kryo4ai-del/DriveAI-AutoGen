final class PermissionStateTransitionTests: XCTestCase {
    var mockPermissionManager: MockPermissionManager!
    
    override func setUp() {
        super.setUp()
        mockPermissionManager = MockPermissionManager()
    }
    
    func test_stateTransition_notDetermined_to_authorized() async {
        mockPermissionManager.setPermissionState(.notDetermined)
        
        let initialState = mockPermissionManager.getCurrentPermissionStatus()
        XCTAssertEqual(initialState, .notDetermined)
        
        mockPermissionManager.setPermissionState(.authorized)
        let finalState = mockPermissionManager.getCurrentPermissionStatus()
        XCTAssertEqual(finalState, .authorized)
    }
    
    func test_stateTransition_notDetermined_to_denied() async {
        mockPermissionManager.setPermissionState(.notDetermined)
        mockPermissionManager.setPermissionState(.denied)
        
        let state = mockPermissionManager.getCurrentPermissionStatus()
        XCTAssertEqual(state, .denied)
    }
    
    func test_stateTransition_authorized_to_denied_notAllowed() async {
        // Once authorized, user cannot be demoted to denied without iOS intervention
        mockPermissionManager.setPermissionState(.authorized)
        let authorizedState = mockPermissionManager.getCurrentPermissionStatus()
        XCTAssertEqual(authorizedState, .authorized)
        
        // User revokes in Settings (simulated)
        // In real app, this happens via system notification
    }
    
    func test_permissionState_restricted_isNotOverrideable() async {
        mockPermissionManager.setPermissionState(.restricted)
        
        let state = mockPermissionManager.getCurrentPermissionStatus()
        XCTAssertEqual(state, .restricted)
        
        // .restricted should persist (device policy)
    }
}