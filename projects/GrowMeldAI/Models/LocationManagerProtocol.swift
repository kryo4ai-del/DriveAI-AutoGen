// Sources/Features/Location/Services/LocationManager.swift
import CoreLocation
import Foundation

protocol LocationManagerProtocol: AnyObject, Sendable {
    func requestWhenInUseAuthorization() async -> LocationPermissionStatus
    func getCurrentPermissionStatus() -> LocationPermissionStatus
    func startUpdatingLocation() -> AsyncStream<LocationData>
    func stopUpdatingLocation()
}

// Step 1: Separate delegate handler (NOT an actor)
private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var authorizationHandler: ((LocationPermissionStatus) -> Void)?
    var locationHandler: ((LocationData) -> Void)?
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        authorizationHandler?(status.toLocationPermissionStatus())
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        for location in locations {
            locationHandler?(LocationData(from: location))
        }
    }
}

// Step 2: Actor uses delegate callbacks to feed streams
@MainActor