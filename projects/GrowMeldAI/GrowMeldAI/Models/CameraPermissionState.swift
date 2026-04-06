import Foundation

enum CameraPermissionState: String, Hashable, CaseIterable {
    case notDetermined = "notDetermined"
    case granted = "granted"
    case denied = "denied"
    case restricted = "restricted"
    
    var displayName: String {
        switch self {
        case .notDetermined:
            return NSLocalizedString("permission.pending", value: "Pending", comment: "")
        case .granted:
            return NSLocalizedString("permission.granted", value: "Granted", comment: "")
        case .denied:
            return NSLocalizedString("permission.denied", value: "Denied", comment: "")
        case .restricted:
            return NSLocalizedString("permission.restricted", value: "Restricted", comment: "")
        }
    }
    
    var isGranted: Bool {
        self == .granted
    }
    
    var isDenied: Bool {
        self == .denied
    }
}