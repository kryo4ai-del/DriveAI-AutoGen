// Separate delegate (safe for background threads)
private class _LocationDelegate: NSObject, CLLocationManagerDelegate {
    var onLocationUpdate: ((LocationData) -> Void)?
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        for location in locations {
            onLocationUpdate?(LocationData(from: location))  // ✅ Safe
        }
    }
}

// Actor wraps delegate
@MainActor
final class LocationManager: LocationManagerProtocol {
    private let delegate = _LocationDelegate()
    
    init() {
        manager.delegate = delegate
        delegate.onLocationUpdate = { [weak self] data in
            Task { @MainActor in
                self?.locationContinuation?.yield(data)  // ✅ Safe
            }
        }
    }
}