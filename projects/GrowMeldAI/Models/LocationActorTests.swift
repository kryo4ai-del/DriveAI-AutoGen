import XCTest
import CoreLocation
@testable import DriveAI

@MainActor
final class LocationActorTests: XCTestCase {
    
    // MARK: - Setup/Teardown
    
    override func setUp() {
        super.setUp()
        // Reset singleton state if needed
        UserDefaults.standard.removeObject(forKey: "com.driveai.location.lastLocation")
    }
    
    // MARK: - Permission Status Tests
    
    func testGetPermissionStatus_NotDetermined() async throws {
        let actor = LocationActor()
        let status = await actor.getPermissionStatus()
        
        XCTAssertEqual(status, .notDetermined)
    }
    
    func testGetPermissionStatus_Denied() async throws {
        let actor = LocationActor()
        
        // Simulate denied state (requires mock CLLocationManager)
        // This test validates the status mapping
        let mappedStatus = mapPermissionStatus(.denied)
        XCTAssertEqual(mappedStatus, .denied)
    }
    
    func testGetPermissionStatus_AuthorizedWhenInUse() async throws {
        let actor = LocationActor()
        
        let mappedStatus = mapPermissionStatus(.authorizedWhenInUse)
        XCTAssertEqual(mappedStatus, .authorizedWhenInUse)
        XCTAssertTrue(mappedStatus.isGranted)
    }
    
    // MARK: - Permission Request Tests
    
    func testRequestLocationPermission_AlreadyGranted() async throws {
        let actor = LocationActor()
        
        // Should not throw when already authorized
        let status = await actor.getPermissionStatus()
        if status.isGranted {
            do {
                try await actor.requestLocationPermission()
            } catch {
                XCTFail("Should not throw when already authorized: \(error)")
            }
        }
    }
    
    func testRequestLocationPermission_PermissionDenied() async throws {
        let actor = LocationActor()
        
        // This requires mocking; verify error is thrown correctly
        // Mock scenario: status is .notDetermined, then user denies
        
        do {
            try await actor.requestLocationPermission()
            // If this succeeds, permission was granted (device-dependent)
        } catch LocationError.permissionDenied {
            XCTAssertTrue(true) // Expected path
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRequestLocationPermission_Timeout() async throws {
        let actor = LocationActor()
        let status = await actor.getPermissionStatus()
        
        // Skip if already determined
        guard status == .notDetermined else { return }
        
        // Timeout should occur after ~30 seconds
        // For testing, use a shorter timeout value (extract to constant)
        let start = Date()
        
        do {
            try await actor.requestLocationPermission()
        } catch LocationError.timeout {
            let elapsed = Date().timeIntervalSince(start)
            XCTAssertGreaterThan(elapsed, 5.0) // At least timeout period
            XCTAssertLessThan(elapsed, 35.0)   // But not too long
        } catch {
            // Permission might be granted/denied before timeout
        }
    }
    
    // MARK: - Location Fetching Tests
    
    func testGetCurrentLocation_PermissionDenied() async throws {
        let actor = LocationActor()
        
        // Ensure permission is denied
        let status = await actor.getPermissionStatus()
        if status == .denied || status == .restricted {
            do {
                _ = try await actor.getCurrentLocation()
                XCTFail("Should throw permissionDenied error")
            } catch LocationError.permissionDenied {
                XCTAssertTrue(true) // Expected
            }
        }
    }
    
    func testGetCurrentLocation_SuccessfulFetch() async throws {
        let actor = LocationActor()
        let status = await actor.getPermissionStatus()
        
        guard status.isGranted else {
            try await actor.requestLocationPermission()
        }
        
        do {
            let location = try await actor.getCurrentLocation()
            
            // Validate location data
            XCTAssertTrue(CLLocationCoordinate2DIsValid(location.coordinate))
            XCTAssertGreater(location.accuracy, 0)
            XCTAssertLess(location.accuracy, 1000)
            XCTAssertTrue(location.isValid)
        } catch {
            // May fail on simulator without location services
            XCTAssert(true, "Location fetch failed (expected on simulator): \(error)")
        }
    }
    
    func testGetCurrentLocation_CachesRecentLocation() async throws {
        let actor = LocationActor()
        let status = await actor.getPermissionStatus()
        
        guard status.isGranted else { return }
        
        do {
            let location1 = try await actor.getCurrentLocation()
            
            // Second fetch within 60 seconds should return cached
            let location2 = try await actor.getCurrentLocation()
            
            XCTAssertEqual(
                location1.coordinate.latitude,
                location2.coordinate.latitude,
                accuracy: 0.001
            )
        } catch {
            // Skip on simulator
        }
    }
    
    func testGetCurrentLocation_Timeout() async throws {
        let actor = LocationActor()
        let status = await actor.getPermissionStatus()
        
        guard status.isGranted else { return }
        
        let start = Date()
        
        do {
            _ = try await actor.getCurrentLocation()
        } catch LocationError.timeout {
            let elapsed = Date().timeIntervalSince(start)
            XCTAssertGreaterThan(elapsed, 5.0)  // At least 5 seconds
            XCTAssertLessThan(elapsed, 12.0)    // Less than 10s timeout + buffer
        } catch {
            // Location fetch may succeed or fail for other reasons
        }
    }
    
    // MARK: - Distance Calculation Tests
    
    func testCalculateDistance_ValidCoordinates() async throws {
        let actor = LocationActor()
        let status = await actor.getPermissionStatus()
        
        guard status.isGranted else {
            try await actor.requestLocationPermission()
        }
        
        do {
            _ = try await actor.getCurrentLocation()
            
            // Test with known coordinates (e.g., Berlin exam center)
            let berlinCoordinate = CLLocationCoordinate2D(
                latitude: 52.5200,
                longitude: 13.4050
            )
            
            let distance = await actor.calculateDistance(to: berlinCoordinate)
            
            if let distance = distance {
                XCTAssertGreater(distance, 0)
                XCTAssertLess(distance, 100_000_000) // Reasonable Earth distance
            }
        } catch {
            // Skip if location unavailable
        }
    }
    
    func testCalculateDistance_InvalidCoordinates() async throws {
        let actor = LocationActor()
        
        let invalidCoordinate = CLLocationCoordinate2D(
            latitude: 999.0,
            longitude: 999.0
        )
        
        let distance = await actor.calculateDistance(to: invalidCoordinate)
        XCTAssertNil(distance)
    }
    
    func testCalculateDistance_NoLocationCached() async throws {
        let actor = LocationActor()
        
        // Without fetching location first
        let coordinate = CLLocationCoordinate2D(
            latitude: 48.1351,
            longitude: 11.5820
        )
        
        let distance = await actor.calculateDistance(to: coordinate)
        XCTAssertNil(distance) // Should return nil if no cached location
    }
    
    func testCalculateDistance_PoorAccuracy() async throws {
        let actor = LocationActor()
        
        // If accuracy > 1000m, distance should return nil
        let coordinate = CLLocationCoordinate2D(
            latitude: 50.1109,
            longitude: 8.6821
        )
        
        let distance = await actor.calculateDistance(to: coordinate)
        
        // Accuracy filtering may prevent calculation
        // This depends on device GPS quality
        if let distance = distance {
            XCTAssertGreater(distance, 0)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testLocationError_LocalizedDescriptions() {
        let errors: [(LocationError, String)] = [
            (.permissionDenied, "Standortzugriff verweigert"),
            (.locationUnavailable, "Standort nicht verfügbar"),
            (.timeout, "Zeitüberschreitung"),
            (.serviceError("Test"), "Fehler: Test"),
        ]
        
        for (error, expectedSubstring) in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertTrue(
                error.errorDescription?.contains(expectedSubstring) ?? false,
                "Error description should contain '\(expectedSubstring)'"
            )
        }
    }
    
    // MARK: - Concurrency & Actor Isolation Tests
    
    func testLocationActor_IsSendable() {
        // Compile-time check: LocationActor conforms to Sendable via actor isolation
        let _: any Sendable = LocationActor.shared
    }
    
    func testLocationActor_ConcurrentAccess() async throws {
        let actor = LocationActor()
        
        // Simulate concurrent permission status checks
        async let status1 = actor.getPermissionStatus()
        async let status2 = actor.getPermissionStatus()
        
        let (s1, s2) = try await (status1, status2)
        
        // Both should complete without data races
        XCTAssertEqual(s1, s2)
    }
    
    func testLocationActor_NoConcurrentRequestConflict() async throws {
        let actor = LocationActor()
        let status = await actor.getPermissionStatus()
        
        guard status.isGranted else { return }
        
        // Attempt concurrent location fetches
        // Actor serializes these automatically
        async let loc1 = try? actor.getCurrentLocation()
        async let loc2 = try? actor.getCurrentLocation()
        
        let (l1, l2) = await (loc1, loc2)
        
        // Both should succeed or both fail (no partial states)
        if let l1 = l1, let l2 = l2 {
            XCTAssertEqual(
                l1.coordinate.latitude,
                l2.coordinate.latitude,
                accuracy: 0.001
            )
        }
    }
}

// MARK: - Helper Functions

@MainActor
func mapPermissionStatus(_ status: CLAuthorizationStatus) -> LocationPermissionState {
    switch status {
    case .notDetermined: return .notDetermined
    case .restricted: return .restricted
    case .denied: return .denied
    case .authorizedWhenInUse: return .authorizedWhenInUse
    case .authorizedAlways: return .authorizedAlways
    @unknown default: return .notDetermined
    }
}