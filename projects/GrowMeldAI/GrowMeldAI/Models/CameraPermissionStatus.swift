import Foundation

enum CameraPermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
    
    var isAuthorized: Bool {
        self == .authorized
    }
    
    var localizedDescription: String {
        switch self {
        case .notDetermined:
            return "Berechtigung erforderlich"
        case .authorized:
            return "Berechtigung erteilt"
        case .denied:
            return "Berechtigung verweigert"
        case .restricted:
            return "Berechtigung beschränkt"
        }
    }
}