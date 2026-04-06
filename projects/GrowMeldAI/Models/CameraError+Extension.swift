import Foundation
extension CameraError {
    /// Short description suitable for VoiceOver announcements
    var accessibilityLabel: String {
        switch self {
        case .permissionDenied:
            return NSLocalizedString(
                "accessibility.camera.error.permissionDenied",
                value: "Camera permission denied",
                comment: "Short VoiceOver label"
            )
        case .permissionRestricted:
            return NSLocalizedString(
                "accessibility.camera.error.permissionRestricted",
                value: "Camera permission restricted",
                comment: "Short VoiceOver label"
            )
        case .hardwareUnavailable:
            return NSLocalizedString(
                "accessibility.camera.error.noCamera",
                value: "No camera available",
                comment: "Short VoiceOver label"
            )
        case .sessionSetupFailed(let reason):
            return NSLocalizedString(
                "accessibility.camera.error.setupFailed",
                value: "Camera setup failed",
                comment: "Short VoiceOver label"
            )
        case .captureFailed:
            return NSLocalizedString(
                "accessibility.camera.error.captureFailed",
                value: "Photo capture failed",
                comment: "Short VoiceOver label"
            )
        case .sessionStartFailed:
            return NSLocalizedString(
                "accessibility.camera.error.sessionStartFailed",
                value: "Camera session start failed",
                comment: "Short VoiceOver label"
            )
        case .unknown:
            return NSLocalizedString(
                "accessibility.camera.error.unknown",
                value: "Camera error",
                comment: "Short VoiceOver label"
            )
        }
    }
    
    /// Detailed description for alert body / detailed UI
    var accessibilityHint: String? {
        return recoverySuggestion  // Use existing detailed suggestion
    }
}