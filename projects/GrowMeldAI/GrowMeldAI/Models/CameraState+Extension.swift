// Add to CameraState:
extension CameraState {
    /// Accessibility-friendly description of current state
    var accessibilityDescription: String {
        if !permissionStatus.isGranted {
            switch permissionStatus {
            case .denied:
                return NSLocalizedString(
                    "accessibility.camera.permissionDenied",
                    value: "Camera permission denied",
                    comment: "For VoiceOver"
                )
            case .restricted:
                return NSLocalizedString(
                    "accessibility.camera.permissionRestricted",
                    value: "Camera permission restricted",
                    comment: "For VoiceOver"
                )
            default:
                return NSLocalizedString(
                    "accessibility.camera.permissionNotDetermined",
                    value: "Camera permission not determined",
                    comment: "For VoiceOver"
                )
            }
        }
        
        switch sessionState {
        case .notInitialized:
            return NSLocalizedString(
                "accessibility.camera.notInitialized",
                value: "Camera not ready",
                comment: "For VoiceOver"
            )
        case .initializing:
            return NSLocalizedString(
                "accessibility.camera.initializing",
                value: "Camera initializing",
                comment: "For VoiceOver"
            )
        case .ready:
            return NSLocalizedString(
                "accessibility.camera.ready",
                value: "Camera ready to capture",
                comment: "For VoiceOver"
            )
        case .capturing:
            return NSLocalizedString(
                "accessibility.camera.capturing",
                value: "Capturing photo",
                comment: "For VoiceOver"
            )
        case .failed(let error):
            return NSLocalizedString(
                "accessibility.camera.failed",
                value: "Camera failed: \(error.localizationKey)",
                comment: "For VoiceOver"
            )
        }
    }
}