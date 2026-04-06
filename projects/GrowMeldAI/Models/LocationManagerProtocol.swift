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
final class LocationManager: NSObject, LocationManagerProtocol {
    nonisolated func getCurrentPermissionStatus() -> LocationPermissionStatus {
        return CLLocationManager.authorizationStatus().toLocationPermissionStatus()
    }

    private let clLocationManager = CLLocationManager()
    private let delegateHandler = LocationManagerDelegate()

    override init() {
        super.init()
        clLocationManager.delegate = delegateHandler
    }

    func requestWhenInUseAuthorization() async -> LocationPermissionStatus {
        return await withCheckedContinuation { continuation in
            delegateHandler.authorizationHandler = { status in
                continuation.resume(returning: status)
            }
            clLocationManager.requestWhenInUseAuthorization()
        }
    }

    func startUpdatingLocation() -> AsyncStream<LocationData> {
        let stream = AsyncStream<LocationData> { continuation in
            delegateHandler.locationHandler = { locationData in
                continuation.yield(locationData)
            }
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.clLocationManager.stopUpdatingLocation()
                }
            }
            clLocationManager.startUpdatingLocation()
        }
        return stream
    }

    func stopUpdatingLocation() {
        clLocationManager.stopUpdatingLocation()
        delegateHandler.locationHandler = nil
    }
}