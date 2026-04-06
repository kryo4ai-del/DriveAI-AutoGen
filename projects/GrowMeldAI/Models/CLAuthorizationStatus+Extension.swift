import CoreLocation
import Foundation

// MARK: - Location Permission Status

enum LocationPermissionStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
    case unknown
}

// MARK: - CLAuthorizationStatus Extension

extension CLLocationManager {
    var locationPermissionStatus: LocationPermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        return LocationPermissionStatus(from: status)
    }
}

extension LocationPermissionStatus {
    init(from status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorizedAlways:
            self = .authorizedAlways
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        @unknown default:
            self = .unknown
        }
    }

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