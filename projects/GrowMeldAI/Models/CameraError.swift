import Foundation

enum CameraError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case hardwareUnavailable
    case sessionSetupFailed(String)
    case sessionStartFailed
    case captureFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString(
                "camera.error.permissionDenied",
                value: "Camera permission denied",
                comment: "Error description"
            )
        case .permissionRestricted:
            return NSLocalizedString(
                "camera.error.permissionRestricted",
                value: "Camera permission restricted",
                comment: "Error description"
            )
        case .hardwareUnavailable:
            return NSLocalizedString(
                "camera.error.hardwareUnavailable",
                value: "Camera hardware unavailable",
                comment: "Error description"
            )
        case .sessionSetupFailed(let reason):
            return String(format: NSLocalizedString(
                "camera.error.sessionSetupFailed",
                value: "Camera session setup failed: %@",
                comment: "Error description"
            ), reason)
        case .sessionStartFailed:
            return NSLocalizedString(
                "camera.error.sessionStartFailed",
                value: "Camera session failed to start",
                comment: "Error description"
            )
        case .captureFailed:
            return NSLocalizedString(
                "camera.error.captureFailed",
                value: "Photo capture failed",
                comment: "Error description"
            )
        case .unknown:
            return NSLocalizedString(
                "camera.error.unknown",
                value: "An unknown camera error occurred",
                comment: "Error description"
            )
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString(
                "camera.error.permissionDenied.recovery",
                value: "Please allow camera access in Settings.",
                comment: "Recovery suggestion"
            )
        case .permissionRestricted:
            return NSLocalizedString(
                "camera.error.permissionRestricted.recovery",
                value: "Camera access is restricted on this device.",
                comment: "Recovery suggestion"
            )
        case .hardwareUnavailable:
            return NSLocalizedString(
                "camera.error.hardwareUnavailable.recovery",
                value: "No camera is available on this device.",
                comment: "Recovery suggestion"
            )
        case .sessionSetupFailed:
            return NSLocalizedString(
                "camera.error.sessionSetupFailed.recovery",
                value: "Try restarting the app.",
                comment: "Recovery suggestion"
            )
        case .sessionStartFailed:
            return NSLocalizedString(
                "camera.error.sessionStartFailed.recovery",
                value: "Try again.",
                comment: "Recovery suggestion"
            )
        case .captureFailed:
            return NSLocalizedString(
                "camera.error.captureFailed.recovery",
                value: "Try capturing the photo again.",
                comment: "Recovery suggestion"
            )
        case .unknown:
            return NSLocalizedString(
                "camera.error.unknown.recovery",
                value: "Please try again.",
                comment: "Recovery suggestion"
            )
        }
    }

    var canRetry: Bool {
        switch self {
        case .sessionStartFailed, .captureFailed:
            return true
        default:
            return false
        }
    }

    var suggestedAction: CameraErrorAction? {
        switch self {
        case .permissionDenied:
            return .openSettings
        case .sessionStartFailed, .captureFailed:
            return .retry
        default:
            return nil
        }
    }
}

enum CameraErrorAction {
    case openSettings
    case retry
}