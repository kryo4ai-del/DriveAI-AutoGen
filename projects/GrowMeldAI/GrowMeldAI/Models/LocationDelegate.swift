final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    weak var service: LocationService?  // ← Weak, but actor won't call back
    
    nonisolated func locationManager(...) {
        Task {
            await service?.handleLocationUpdate(location)  // ← Can be nil
        }
    }
}