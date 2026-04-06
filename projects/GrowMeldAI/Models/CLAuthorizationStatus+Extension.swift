import CoreLocation
import Foundation

// MARK: - Location Permission Status

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

// MARK: - LocationPermissionStatus

enum LocationPermissionStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
    case unknown

    var isAuthorized: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    var isDenied: Bool {
        switch self {
        case .denied, .restricted:
            return true
        default:
            return false
        }
    }

    var isPending: Bool {
        return self == .notDetermined
    }

    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .unknown:
            return "Unknown"
        }
    }
}