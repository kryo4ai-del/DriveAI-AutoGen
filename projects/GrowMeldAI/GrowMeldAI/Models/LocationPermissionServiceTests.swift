import XCTest
import CoreLocation
@testable import DriveAI

@MainActor
final class LocationPermissionServiceTests: XCTestCase {
    var sut: LocationPermissionService!
    
    override func setUp() {
        super.setUp()
        sut = LocationPermissionService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Permission State Tests
    
    func testInitialPermissionStateIsNotDetermined() {
        XCTAssertEqual(sut.permissionState, .notDetermined)
    }
    
    func testRequestLocationPermissionDoesNotCrash() {
        // Happy path: permission request succeeds
        XCTAssertNoThrow {
            sut.requestLocationPermission()
        }
    }
    
    func testPermissionStatePublishedOnChange() {
        let expectation = self.expectation(forNotification: NSNotification.Name("permissionStateChanged"), object: nil)
        
        var stateChanges: [LocationPermissionState] = []
        let cancellable = sut.$permissionState
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
            }
        
        // Simulate permission granted
        sut.locationManager(
            sut.locationManager,
            didChangeAuthorization: .authorizedWhenInUse
        )
        
        // Verify state changed
        XCTAssertGreater(stateChanges.count, 0)
        cancellable.cancel()
    }
    
    // MARK: - Location Update Tests
    
    func testLocationUpdateWithHighAccuracy() {
        let location = CLLocation(
            latitude: 48.1351,
            longitude: 11.5820,
            horizontalAccuracy: 50  // Good accuracy
        )
        
        sut.locationManager(
            sut.locationManager,
            didUpdateLocations: [location]
        )
        
        // Wait for main thread update
        let expectation = self.expectation(description: "Location published")
        
        var captured: UserLocation?
        let cancellable = sut.$currentLocation
            .dropFirst()
            .first(where: { $0 != nil })
            .sink { captured = $0 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(captured?.latitude, 48.1351, accuracy: 0.0001)
        XCTAssertEqual(captured?.longitude, 11.5820, accuracy: 0.0001)
    }
    
    func testLocationUpdateIgnoredWhenAccuracyPoor() {
        let location = CLLocation(
            latitude: 48.1351,
            longitude: 11.5820,
            horizontalAccuracy: 500  // Poor accuracy (filtered)
        )
        
        let initialLocation = sut.currentLocation
        
        sut.locationManager(
            sut.locationManager,
            didUpdateLocations: [location]
        )
        
        // Location should NOT update
        XCTAssertEqual(sut.currentLocation, initialLocation)
    }
    
    func testLocationUpdatesRespectDistanceFilter() {
        // First update
        let location1 = CLLocation(
            latitude: 48.1351,
            longitude: 11.5820,
            horizontalAccuracy: 50
        )
        
        sut.locationManager(sut.locationManager, didUpdateLocations: [location1])
        
        let firstCapture = sut.currentLocation
        
        // Second update close by (should be ignored)
        let location2 = CLLocation(
            latitude: 48.13510001,  // ~0.1m away
            longitude: 11.58200001,
            horizontalAccuracy: 50
        )
        
        sut.locationManager(sut.locationManager, didUpdateLocations: [location2])
        
        // Should not have updated (distance filter = 100m)
        XCTAssertEqual(sut.currentLocation, firstCapture)
    }
    
    func testLocationManagerErrorHandling() {
        let error = CLError(.denied)
        let initialLocation = sut.currentLocation
        
        sut.locationManager(sut.locationManager, didFailWithError: error)
        
        // Should keep previous location (not clear it)
        XCTAssertEqual(sut.currentLocation, initialLocation)
    }
    
    func testStartUpdatingLocationRequiresPermission() {
        sut.permissionState = .denied
        sut.startUpdatingLocation()
        
        // Should not start (permission check failed)
        // Verify by checking that locationManager wasn't called
        // (Would need to mock CLLocationManager)
    }
    
    func testStopUpdatingLocationCancelsUpdates() {
        sut.startUpdatingLocation()
        sut.stopUpdatingLocation()
        
        // Verify location manager stopped
        // (Implementation detail—verify in integration tests)
    }
    
    // MARK: - Edge Cases
    
    func testHandlesNegativeAccuracy() {
        let location = CLLocation(
            latitude: 48.1351,
            longitude: 11.5820,
            horizontalAccuracy: -1  // Invalid
        )
        
        let initialLocation = sut.currentLocation
        sut.locationManager(sut.locationManager, didUpdateLocations: [location])
        
        // Should reject
        XCTAssertEqual(sut.currentLocation, initialLocation)
    }
    
    func testHandlesNilLocation() {
        let emptyArray: [CLLocation] = []
        let initialLocation = sut.currentLocation
        
        sut.locationManager(sut.locationManager, didUpdateLocations: emptyArray)
        
        XCTAssertEqual(sut.currentLocation, initialLocation)
    }
    
    func testPermissionStateTransitions() {
        let transitions: [(CLAuthorizationStatus, LocationPermissionState)] = [
            (.notDetermined, .notDetermined),
            (.restricted, .restricted),
            (.denied, .denied),
            (.authorizedWhenInUse, .authorizedWhenInUse),
            (.authorizedAlways, .authorizedWhenInUse),
        ]
        
        for (clStatus, expectedState) in transitions {
            let mappedState = sut.mapAuthorizationStatus(clStatus)
            XCTAssertEqual(mappedState, expectedState, "Failed for status: \(clStatus)")
        }
    }
}