// Tests/Unit/LocationTypesTests.swift
import XCTest
import CoreLocation
@testable import DriveAI

final class LocationTypesTests: XCTestCase {
    
    // MARK: - LocationPermissionStatus Tests
    
    func test_locationPermissionStatus_authorized_returns_true() {
        XCTAssertTrue(LocationPermissionStatus.authorizedWhenInUse.isAuthorized)
        XCTAssertTrue(LocationPermissionStatus.authorizedAlways.isAuthorized)
    }
    
    func test_locationPermissionStatus_notAuthorized_returns_false() {
        XCTAssertFalse(LocationPermissionStatus.denied.isAuthorized)
        XCTAssertFalse(LocationPermissionStatus.notDetermined.isAuthorized)
        XCTAssertFalse(LocationPermissionStatus.restricted.isAuthorized)
    }
    
    // MARK: - LocationError Tests
    
    func test_locationError_localizedDescriptions_notEmpty() {
        let errors: [LocationError] = [
            .permissionDenied,
            .serviceDisabled,
            .invalidExamCenter,
            .calculationFailed,
            .locationUnavailable,
            .timeout
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
        }
    }
    
    func test_locationError_equatable() {
        let error1 = LocationError.permissionDenied
        let error2 = LocationError.permissionDenied
        let error3 = LocationError.serviceDisabled
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    // MARK: - LocationData Tests
    
    func test_locationData_initialization() {
        let location = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: Date(),
            accuracy: 50
        )
        
        XCTAssertEqual(location.latitude, 52.52)
        XCTAssertEqual(location.longitude, 13.405)
        XCTAssertEqual(location.accuracy, 50)
    }
    
    func test_locationData_equatable() {
        let date = Date()
        let location1 = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: date,
            accuracy: 50
        )
        let location2 = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: date,
            accuracy: 50
        )
        
        XCTAssertEqual(location1, location2)
    }
    
    // MARK: - DistanceInfo Tests
    
    func test_distanceInfo_lessThan1Meter_displaysMeters() {
        let distance = DistanceInfo(kilometers: 0.0001)  // 0.1m
        
        XCTAssertEqual(distance.displayValue, "< 1 m")
    }
    
    func test_distanceInfo_lessThan1Km_displaysMeters() {
        let distance = DistanceInfo(kilometers: 0.5)
        
        XCTAssertEqual(distance.displayValue, "500 m")
    }
    
    func test_distanceInfo_1to100Km_displaysKilometersOneDecimal() {
        let distance = DistanceInfo(kilometers: 12.567)
        
        XCTAssertEqual(distance.displayValue, "12.6 km")
    }
    
    func test_distanceInfo_over100Km_displaysKilometersNoDecimal() {
        let distance = DistanceInfo(kilometers: 250.5)
        
        XCTAssertEqual(distance.displayValue, "250 km")
    }
    
    func test_distanceInfo_negativeDistance_clampsToZero() {
        let distance = DistanceInfo(kilometers: -50)
        
        XCTAssertEqual(distance.kilometers, 0)
        XCTAssertEqual(distance.displayValue, "< 1 m")
    }
    
    func test_distanceInfo_edgeCases() {
        let testCases: [(Double, String)] = [
            (0, "< 1 m"),
            (0.0001, "< 1 m"),
            (0.001, "1 m"),
            (0.999, "999 m"),
            (1.0, "1.0 km"),
            (1.05, "1.1 km"),
            (99.95, "100.0 km"),
            (100.0, "100 km"),
            (100.4, "100 km"),
            (1000.0, "1000 km")
        ]
        
        for (input, expectedOutput) in testCases {
            let distance = DistanceInfo(kilometers: input)
            XCTAssertEqual(
                distance.displayValue,
                expectedOutput,
                "Failed for input \(input)"
            )
        }
    }
}