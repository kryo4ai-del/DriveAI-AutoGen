import CoreLocation

final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    weak var service: LocationService?

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            await service?.handleLocationUpdate(location)
        }
    }
}