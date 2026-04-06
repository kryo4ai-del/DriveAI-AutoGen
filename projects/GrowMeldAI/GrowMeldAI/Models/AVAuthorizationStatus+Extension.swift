extension AVAuthorizationStatus {
    var asPermissionStatus: CameraPermissionStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            // Future-proof: iOS adds new statuses
            return .notDetermined
        }
    }
}