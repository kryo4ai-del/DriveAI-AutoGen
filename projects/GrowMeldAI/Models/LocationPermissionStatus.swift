import CoreLocation

enum LocationPermissionStatus: Equatable, Hashable {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
    
    var isAuthorized: Bool {
        self == .authorizedAlways || self == .authorizedWhenInUse
    }
    
    var displayName: String {
        switch self {
        case .notDetermined:
            return String(localized: "permission_notdetermined", defaultValue: "Not determined")
        case .restricted:
            return String(localized: "permission_restricted", defaultValue: "Restricted")
        case .denied:
            return String(localized: "permission_denied", defaultValue: "Denied")
        case .authorizedAlways:
            return String(localized: "permission_always", defaultValue: "Always")
        case .authorizedWhenInUse:
            return String(localized: "permission_inuse", defaultValue: "While using app")
        }
    }
}

// MARK: - CLAuthorizationStatus Mapping
extension CLAuthorizationStatus {
    func toLocationPermissionStatus() -> LocationPermissionStatus {
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
            return .notDetermined
        }
    }
}