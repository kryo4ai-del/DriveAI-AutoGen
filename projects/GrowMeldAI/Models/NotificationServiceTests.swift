// Tests/Unit/Services/NotificationServiceTests.swift

import XCTest
import UserNotifications
@testable import DriveAI

final class NotificationServiceTests: XCTestCase {
    var sut: NotificationService!
    var mockCenter: MockUNUserNotificationCenter!
    var mockStore: MockNotificationPreferenceStore!
    
    override func setUp() {
        super.setUp()
        mockCenter = MockUNUserNotificationCenter()
        mockStore = MockNotificationPreferenceStore()
        sut = NotificationService(center: mockCenter, store: mockStore)
    }
    
    // MARK: - Happy Path
    
    func test_requestUserPermission_whenNotDetermined_requestsAndReturnsGranted() async {
        // Given
        mockCenter.mockAuthorizationStatus = .notDetermined
        mockCenter.shouldGrantAuthorization = true
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .authorized)
        XCTAssertTrue(mockCenter.requestAuthorizationCalled)
        XCTAssertEqual(mockStore.savedStatus, .authorized)
    }
    
    func test_requestUserPermission_whenNotDetermined_requestsAndReturnsDenied() async {
        // Given
        mockCenter.mockAuthorizationStatus = .notDetermined
        mockCenter.shouldGrantAuthorization = false
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .denied)
        XCTAssertTrue(mockCenter.requestAuthorizationCalled)
        XCTAssertEqual(mockStore.savedStatus, .denied)
    }
    
    // MARK: - Edge Cases
    
    func test_requestUserPermission_whenAlreadyAuthorized_returnsAuthorizedWithoutRequesting() async {
        // Given
        mockCenter.mockAuthorizationStatus = .authorized
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .authorized)
        XCTAssertFalse(mockCenter.requestAuthorizationCalled)  // Should skip request
    }
    
    func test_requestUserPermission_whenAlreadyDenied_returnsDeniedWithoutRequesting() async {
        // Given
        mockCenter.mockAuthorizationStatus = .denied
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .denied)
        XCTAssertFalse(mockCenter.requestAuthorizationCalled)
    }
    
    func test_requestUserPermission_whenProvisional_returnsProvisionalStatus() async {
        // Given
        mockCenter.mockAuthorizationStatus = .provisional
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .provisional)
        XCTAssertFalse(mockCenter.requestAuthorizationCalled)
    }
    
    func test_requestUserPermission_whenEphemeral_returnsEphemeralStatus() async {
        // Given
        mockCenter.mockAuthorizationStatus = .ephemeral
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .ephemeral)
        XCTAssertFalse(mockCenter.requestAuthorizationCalled)
    }
    
    // MARK: - Error Scenarios
    
    func test_requestUserPermission_onAuthorizationException_returnsденiedAndLogError() async {
        // Given
        mockCenter.mockAuthorizationStatus = .notDetermined
        mockCenter.shouldThrowError = true
        mockCenter.errorToThrow = NSError(domain: "UNNotificationError", code: 1)
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .denied)
        XCTAssertEqual(mockStore.savedStatus, .denied)
        // (Logger would be mocked in real scenario)
    }
    
    func test_requestUserPermission_onSystemRestriction_returnsdeniedGracefully() async {
        // Given: Device with MDM restriction
        mockCenter.mockAuthorizationStatus = .notDetermined
        mockCenter.shouldThrowError = true
        mockCenter.errorToThrow = NSError(
            domain: UNNotificationError.notSupported.rawValue.description,
            code: UNNotificationError.notSupported.rawValue
        )
        
        // When
        let status = await sut.requestUserPermission()
        
        // Then
        XCTAssertEqual(status, .denied)
        XCTAssertTrue(mockStore.savedStatus == .denied)
    }
    
    // MARK: - Concurrent Requests
    
    func test_requestUserPermission_multipleConcurrentRequests_handlesConcurrency() async {
        // Given
        mockCenter.mockAuthorizationStatus = .notDetermined
        mockCenter.shouldGrantAuthorization = true
        mockCenter.requestDelay = 0.1  // Simulate slow permission dialog
        
        // When: Fire multiple concurrent requests
        async let request1 = sut.requestUserPermission()
        async let request2 = sut.requestUserPermission()
        async let request3 = sut.requestUserPermission()
        
        let (status1, status2, status3) = await (request1, request2, request3)
        
        // Then: All should succeed (or all fail consistently)
        XCTAssertEqual(status1, .authorized)
        XCTAssertEqual(status2, .authorized)
        XCTAssertEqual(status3, .authorized)
        // RequestAuthorization should only be called once (deduplicated)
        XCTAssertEqual(mockCenter.requestAuthorizationCallCount, 1)
    }
    
    // MARK: - isNotificationEnabled
    
    func test_isNotificationEnabled_whenEnabled_returnsTrue() {
        // Given
        mockStore.isEnabledValue = true
        
        // When
        let result = sut.isNotificationEnabled()
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_isNotificationEnabled_whenDisabled_returnsFalse() {
        // Given
        mockStore.isEnabledValue = false
        
        // When
        let result = sut.isNotificationEnabled()
        
        // Then
        XCTAssertFalse(result)
    }
}

// MARK: - Mock Objects

final class MockUNUserNotificationCenter: UNUserNotificationCenter {
    var mockAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var shouldGrantAuthorization = false
    var shouldThrowError = false
    var errorToThrow: Error?
    var requestDelay: TimeInterval = 0
    
    var requestAuthorizationCalled = false
    var requestAuthorizationCallCount = 0
    
    override func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestAuthorizationCalled = true
        requestAuthorizationCallCount += 1
        
        if requestDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
        }
        
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        return shouldGrantAuthorization
    }
    
    override func notificationSettings() async -> UNNotificationSettings {
        // Return mock settings with specified authorization status
        let settings = MockUNNotificationSettings(authorizationStatus: mockAuthorizationStatus)
        return settings
    }
}

final class MockNotificationPreferenceStore: NotificationPreferenceStore {
    var isEnabledValue = false
    var savedStatus: UNAuthorizationStatus?
    
    override var isEnabled: Bool {
        isEnabledValue
    }
    
    override func setPermissionStatus(_ status: UNAuthorizationStatus) {
        savedStatus = status
    }
}