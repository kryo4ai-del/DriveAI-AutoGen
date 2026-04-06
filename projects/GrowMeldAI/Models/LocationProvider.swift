import CoreLocation

/// Protocol for location service abstraction (enables testing)
protocol LocationProvider: AnyObject, Sendable {
    func requestWhenInUseAuthorization() async -> CLAuthorizationStatus
    func startMonitoringLocation() async
    func stopMonitoringLocation()
    func getCurrentLocation() async -> UserLocationContext?
}