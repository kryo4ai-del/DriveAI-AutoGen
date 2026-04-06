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
final class LocationManager: LocationManagerProtocol {
    nonisolated init() {}

    nonisolated func getCurrentPermissionStatus() -> LocationPermissionStatus {
        return CLLocationManager.authorizationStatus().toLocationPermissionStatus()
    }

    func requestWhenInUseAuthorization() async -> LocationPermissionStatus {
        let manager = CLLocationManager()
        let delegate = LocationManagerDelegate()
        manager.delegate = delegate

        return await withCheckedContinuation { continuation in
            delegate.authorizationHandler = { status in
                continuation.resume(returning: status)
            }
            manager.requestWhenInUseAuthorization()
        }
    }

    func startUpdatingLocation() -> AsyncStream<LocationData> {
        let manager = CLLocationManager()
        let delegate = LocationManagerDelegate()
        manager.delegate = delegate

        return AsyncStream { continuation in
            delegate.locationHandler = { data in
                continuation.yield(data)
            }
            continuation.onTermination = { @Sendable _ in
                manager.stopUpdatingLocation()
            }
            manager.startUpdatingLocation()
        }
    }

    func stopUpdatingLocation() {
        // No-op or manage stored manager if needed
    }
}