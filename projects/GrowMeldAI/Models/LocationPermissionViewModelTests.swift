// Sources/Features/Location/Tests/LocationPermissionViewModelTests.swift
import XCTest
@testable import DriveAI

@MainActor
final class LocationPermissionViewModelTests: XCTestCase {
    var sut: LocationPermissionViewModel!
    var mockLocationManager: MockLocationManager!
    
    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        sut = LocationPermissionViewModel(locationManager: mockLocationManager)
    }
    
    func testRequestPermissionWhenNotDetermined() async {
        mockLocationManager.authorizationStatus = .notDetermined
        
        await sut.requestPermission()
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testRequestPermissionWhenDenied() async {
        mockLocationManager.authorizationStatus = .denied
        
        await sut.requestPermission()
        
        XCTAssertEqual(sut.permissionStatus, .denied)
        XCTAssertEqual(sut.error, .permissionDenied)
    }
    
    func testIsAuthorizedReturnsTrue() {
        sut.permissionStatus = .authorizedWhenInUse
        
        XCTAssertTrue(sut.isAuthorized)
    }
    
    func testErrorDismissal() {
        sut.error = .locationServicesDisabled
        sut.dismissError()
        
        XCTAssertNil(sut.error)
    }
}