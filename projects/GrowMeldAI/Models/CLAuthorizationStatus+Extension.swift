import CoreLocation
import Foundation

enum LocationPermissionStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
}

extension CLLocationManager {
    var locationPermissionStatus: LocationPermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        switch status {
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
            return .notDetermined
        }
    }
}