// Domains/LocationDomain/Services/LocationPermissionService.swift
import CoreLocation
import Foundation

@MainActor
final class LocationPermissionService: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var permissionState: LocationPermissionState = .notDetermined
    @Published var currentLocation: UserLocation?
    
    private let locationManager = CLLocationManager()
    private let accuracyThreshold: CLLocationAccuracy = 100 // meters
    private var isUpdating = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = accuracyThreshold
        updatePermissionState()
    }
    
    // MARK: - Public API
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard permissionState == .authorizedWhenInUse else {
            print("⚠️ LocationPermissionService: Cannot start updates—permission not granted")
            return
        }
        isUpdating = true
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        isUpdating = false
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        
        // Filter by accuracy threshold
        guard location.horizontalAccuracy > 0 &&
              location.horizontalAccuracy < accuracyThreshold else { return }
        
        Task { @MainActor in
            self.currentLocation = UserLocation(from: location)
        }
    }
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        let clError = error as? CLError
        print("❌ LocationPermissionService error: \(clError?.localizedDescription ?? error.localizedDescription)")
        
        // Don't update state—keep previous value
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.updatePermissionState()
        }
    }
    
    // MARK: - Private Helpers
    
    private func updatePermissionState() {
        let status = locationManager.authorizationStatus
        permissionState = mapAuthorizationStatus(status)
    }
    
    private func mapAuthorizationStatus(_ status: CLAuthorizationStatus) -> LocationPermissionState {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        case .authorizedAlways:
            return .authorizedWhenInUse
        @unknown default:
            return .notDetermined
        }
    }
}