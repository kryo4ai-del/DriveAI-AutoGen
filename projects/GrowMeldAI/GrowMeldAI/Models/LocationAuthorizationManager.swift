import CoreLocation
import Combine

@MainActor
final class LocationAuthorizationManager: NSObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isDenied: Bool = false
    
    private let locationManager = CLLocationManager()
    private var statusChanges = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestWhenInUseAuthorization() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        isDenied = manager.authorizationStatus == .denied
    }
}