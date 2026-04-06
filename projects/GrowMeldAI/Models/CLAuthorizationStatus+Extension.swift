import CoreLocation
import Foundation

extension CLAuthorizationStatus {
    var locationPermissionStatus: LocationPermissionStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorizedAlways:
            return .authorizedAlways
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        @unknown default:
            return .unknown
        }
    }
}

extension CLLocationManager {
    var locationPermissionStatus: LocationPermissionStatus {
        return authorizationStatus.locationPermissionStatus
    }
}