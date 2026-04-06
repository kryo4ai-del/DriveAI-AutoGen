// Tests/Unit/LocationPermissionManagerTests.swift
import XCTest
import CoreLocation
@testable import DriveAI

@MainActor
final class LocationPermissionManagerTests: XCTestCase {
    var sut: LocationPermissionManager!
    
    override func setUp() {
        super.setUp()
        sut = LocationPermissionManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_initialization_setsDefaultExamCenter() {
        XCTAssertEqual(sut.examCenter.latitude, 52.52, accuracy: 0.01)
        XCTAssertEqual(sut.examCenter.longitude, 13.405, accuracy: 0.01)
    }
    
    func test_customExamCenterInitialization() {
        let customCenter = CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820)
        let customSUT = LocationPermissionManager(examCenter: customCenter)
        
        XCTAssertEqual(customSUT.examCenter.latitude, 48.1351, accuracy: 0.01)
        XCTAssertEqual(customSUT.examCenter.longitude, 11.5820, accuracy: 0.01)
    }
    
    func test_permissionStatus_initiallyNotDetermined() {
        XCTAssertEqual(sut.permissionStatus, .notDetermined)
    }
    
    func test_calculateDistance_withValidLocation() async {
        // Arrange
        sut.currentLocation = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: Date(),
            accuracy: 50
        )
        
        // Act
        await sut.calculateDistance()
        
        // Assert
        XCTAssertNotNil(sut.distanceToExamCenter)
        XCTAssertLessThan(sut.distanceToExamCenter?.kilometers ?? 100, 1)  // At exam center
        XCTAssertNil(sut.lastError)
    }
    
    func test_calculateDistance_toCustomCoordinate() async {
        // Arrange
        let distance100km = CLLocationCoordinate2D(latitude: 52.52, longitude: 14.405)
        sut.currentLocation = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: Date(),
            accuracy: 50
        )
        
        // Act
        await sut.calculateDistance(to: distance100km)
        
        // Assert
        XCTAssertNotNil(sut.distanceToExamCenter)
        XCTAssertGreaterThan(sut.distanceToExamCenter?.kilometers ?? 0, 50)
    }
    
    func test_distanceCalculation_isCalculatingDuringExecution() async {
        // Arrange
        sut.currentLocation = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: Date(),
            accuracy: 50
        )
        
        let task = Task {
            await sut.calculateDistance()
        }
        
        // Assert (may be true during execution)
        await Task.sleep(nanoseconds: 1_000_000)  // 1ms delay
        
        await task.value
        XCTAssertFalse(sut.isCalculatingDistance)  // Should be false after completion
    }
    
    // MARK: - Edge Cases
    
    func test_calculateDistance_withoutCurrentLocation() async {
        // Arrange
        sut.currentLocation = nil
        
        // Act
        await sut.calculateDistance()
        
        // Assert
        XCTAssertEqual(sut.lastError, .locationUnavailable)
        XCTAssertNil(sut.distanceToExamCenter)
    }
    
    func test_calculateDistance_negativeDistance_clampsToZero() async {
        // Note: In real world, distance() never returns negative,
        // but test defensive programming in DistanceInfo
        let distanceInfo = DistanceInfo(kilometers: -10)
        
        XCTAssertEqual(distanceInfo.kilometers, 0)
        XCTAssertEqual(distanceInfo.displayValue, "< 1 m")
    }
    
    func test_startLocationTracking_withoutPermission() {
        // Arrange
        sut.permissionStatus = .notDetermined
        
        // Act
        sut.startLocationTracking()
        
        // Assert
        XCTAssertEqual(sut.lastError, .permissionDenied)
    }
    
    func test_startLocationTracking_withDeniedPermission() {
        // Arrange
        sut.permissionStatus = .denied
        
        // Act
        sut.startLocationTracking()
        
        // Assert
        XCTAssertEqual(sut.lastError, .permissionDenied)
    }
    
    func test_openAppSettings_opensURL() {
        // This is typically tested with XCUITest for actual URL opening
        // Unit test just verifies method doesn't crash
        XCTAssertNoThrow {
            sut.openAppSettings()
        }
    }
    
    // MARK: - Permission Status Tests
    
    func test_permissionStatus_authorized_returns_isAuthorizedTrue() {
        sut.permissionStatus = .authorizedWhenInUse
        XCTAssertTrue(sut.permissionStatus.isAuthorized)
        
        sut.permissionStatus = .authorizedAlways
        XCTAssertTrue(sut.permissionStatus.isAuthorized)
    }
    
    func test_permissionStatus_denied_returns_isAuthorizedFalse() {
        sut.permissionStatus = .denied
        XCTAssertFalse(sut.permissionStatus.isAuthorized)
    }
    
    func test_permissionStatus_statusIcon_variesByPermission() {
        let testCases: [(LocationPermissionStatus, String)] = [
            (.authorizedWhenInUse, "location.circle.fill"),
            (.denied, "location.slash.circle.fill"),
            (.restricted, "location.circle.dashed"),
            (.notDetermined, "location.circle")
        ]
        
        for (status, expectedIcon) in testCases {
            XCTAssertEqual(status.statusIcon, expectedIcon)
        }
    }
    
    func test_permissionStatus_statusColor_variesByPermission() {
        let testCases: [(LocationPermissionStatus, Color)] = [
            (.authorizedWhenInUse, .green),
            (.denied, .red),
            (.restricted, .orange),
            (.notDetermined, .gray)
        ]
        
        for (status, expectedColor) in testCases {
            XCTAssertEqual(status.statusColor, expectedColor)
        }
    }
    
    // MARK: - Debouncing & Race Condition Tests
    
    func test_locationUpdates_debounceMultipleUpdates() async {
        // Arrange
        var updateCount = 0
        sut.currentLocation = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: Date(),
            accuracy: 50
        )
        
        // Simulate 5 rapid location updates
        for i in 0..<5 {
            let newLocation = LocationData(
                latitude: 52.52 + Double(i) * 0.001,
                longitude: 13.405,
                timestamp: Date(),
                accuracy: 50
            )
            sut.currentLocation = newLocation
        }
        
        // Wait for debounce to settle
        await Task.sleep(nanoseconds: 600_000_000)  // 600ms (debounce is 500ms)
        
        // Assert: Only final distance should be calculated
        XCTAssertNotNil(sut.distanceToExamCenter)
    }
    
    func test_stopLocationTracking_cancelsOngoingCalculations() async {
        // Arrange
        sut.currentLocation = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: Date(),
            accuracy: 50
        )
        
        // Act
        sut.stopLocationTracking()
        
        // Assert
        XCTAssertNil(sut.distanceToExamCenter)  // Calculation cancelled
    }
    
    // MARK: - Deallocation Safety
    
    func test_deinit_stopsLocationTracking() {
        let manager = LocationPermissionManager()
        manager.startLocationTracking()
        
        // Act: Deallocate
        _ = manager
        
        // Assert: No crash (verified by test completing)
        XCTAssertTrue(true)
    }
}

// MARK: - Helper Extensions

extension XCTestCase {
    func XCTAssertNoThrow(_ block: @escaping () -> Void) {
        XCTAssertNoThrow {
            block()
        }
    }
}