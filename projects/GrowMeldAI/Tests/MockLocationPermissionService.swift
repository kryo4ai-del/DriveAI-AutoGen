// Tests/LocationDomainTests/Mocks/MockLocationPermissionService.swift
@MainActor
final class MockLocationPermissionService: LocationPermissionService {
    var mockPermissionState: LocationPermissionState = .notDetermined
    var mockLocation: UserLocation?
    var requestPermissionCalled = false
    
    override func requestLocationPermission() {
        requestPermissionCalled = true
    }
    
    // Override other methods for testing
}