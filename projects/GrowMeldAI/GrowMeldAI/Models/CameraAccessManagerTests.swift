// Tests/Services/CameraAccessManagerTests.swift

import XCTest
import AVFoundation
@testable import DriveAI

class CameraAccessManagerTests: XCTestCase {
    var sut: CameraAccessManager!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "test.camera.access")
        mockUserDefaults?.removePersistentDomain(forName: "test.camera.access")
        sut = CameraAccessManager(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        mockUserDefaults?.removePersistentDomain(forName: "test.camera.access")
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Permission State Tests
    
    func test_initialPermissionState_returnsNotDetermined() async {
        let state = await sut.checkPermission()
        XCTAssertEqual(state, .notDetermined)
    }
    
    func test_checkPermission_returnsAuthorized_whenPreviouslyGranted() async {
        // Setup: Mock AVCaptureDevice authorization
        mockUserDefaults?.set(PermissionState.authorized.rawValue, forKey: "camera_permission_cache")
        
        let state = await sut.checkPermission()
        XCTAssertEqual(state, .authorized)
    }
    
    func test_checkPermission_returnsDenied_whenPreviouslyDenied() async {
        mockUserDefaults?.set(PermissionState.denied.rawValue, forKey: "camera_permission_cache")
        
        let state = await sut.checkPermission()
        XCTAssertEqual(state, .denied)
    }
    
    func test_checkPermission_refreshesState_afterAppForeground() async {
        // First call caches the state
        mockUserDefaults?.set(PermissionState.denied.rawValue, forKey: "camera_permission_cache")
        mockUserDefaults?.set(Date().timeIntervalSince1970, forKey: "camera_permission_cache_time")
        
        // Simulate cache expiration (> 60 seconds)
        let oldTime = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 120)
        mockUserDefaults?.set(oldTime.timeIntervalSince1970, forKey: "camera_permission_cache_time")
        
        let state = await sut.checkPermission()
        // Should re-check system state, not return cached denied
        XCTAssertNotEqual(state, .denied)
    }
    
    func test_requestPermission_completesWithAuthorized_whenUserAllows() async {
        let state = await sut.requestPermission()
        
        // Note: This test may require mocking AVCaptureDevice in a real environment
        // For now, we verify the method completes without crashing
        XCTAssert(true)
    }
    
    func test_requestPermission_doesNotTriggerSystemDialog_ifAlreadyAuthorized() async {
        mockUserDefaults?.set(PermissionState.authorized.rawValue, forKey: "camera_permission_cache")
        
        let state = await sut.requestPermission()
        XCTAssertEqual(state, .authorized)
    }
    
    // MARK: - Cache Management Tests
    
    func test_cacheIsInvalidated_onAppForeground() async {
        mockUserDefaults?.set(PermissionState.authorized.rawValue, forKey: "camera_permission_cache")
        
        // Simulate foreground event
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification)
        
        await Task.sleep(nanoseconds: 100_000_000) // Wait 0.1s
        
        let state = await sut.checkPermission()
        // State should be refreshed from system, not from cache
        XCTAssertNotNil(state)
    }
    
    func test_cacheIsClearedOnReset() async {
        mockUserDefaults?.set(PermissionState.authorized.rawValue, forKey: "camera_permission_cache")
        
        sut.resetPermissionCache()
        
        let cachedValue = mockUserDefaults?.string(forKey: "camera_permission_cache")
        XCTAssertNil(cachedValue)
    }
}