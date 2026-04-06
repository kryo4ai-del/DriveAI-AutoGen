import CoreLocation
import Combine

@MainActor
final class DeviceLocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var error: LocationError?
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyCity
    }
    
    // MARK: - Public API
    
    func checkAuthorizationStatus() -> CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        guard locationManager.authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = locationManager.authorizationStatus
        
        guard status != .denied else {
            throw LocationError.locationServicesDenied
        }
        
        guard status != .restricted else {
            throw LocationError.locationServicesDisabled
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.locationContinuation = continuation
            self?.locationManager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        let locationError: LocationError
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .locationServicesDenied
            case .locationUnknown:
                locationError = .geocodingFailed("Standort konnte nicht ermittelt werden")
            default:
                locationError = .unexpectedError(clError.localizedDescription)
            }
        } else {
            locationError = .unexpectedError(error.localizedDescription)
        }
        
        self.error = locationError
        locationContinuation?.resume(throwing: locationError)
        locationContinuation = nil
    }
}