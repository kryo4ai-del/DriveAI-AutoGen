import Foundation

enum CameraError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case hardwareUnavailable
    case sessionSetupFailed(reason: String)
    case sessionStartFailed
    case captureFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("camera.error.permissionDenied", value: "Camera access denied. Please allow camera access in Settings.", comment: "Camera permission denied error")
        case .permissionRestricted:
            return NSLocalizedString("camera.error.permissionRestricted", value: "Camera access is restricted on this device.", comment: "Camera permission restricted error")
        case .hardwareUnavailable:
            return NSLocalizedString("camera.error.hardwareUnavailable", value: "No camera is available on this device.", comment: "Camera hardware unavailable error")
        case .sessionSetupFailed(let reason):
            return String(format: NSLocalizedString("camera.error.sessionSetupFailed", value: "Camera setup failed: %@", comment: "Camera session setup failed error"), reason)
        case .sessionStartFailed:
            return NSLocalizedString("camera.error.sessionStartFailed", value: "Failed to start the camera session.", comment: "Camera session start failed error")
        case .captureFailed:
            return NSLocalizedString("camera.error.captureFailed", value: "Failed to capture photo.", comment: "Camera capture failed error")
        case .unknown:
            return NSLocalizedString("camera.error.unknown", value: "An unknown camera error occurred.", comment: "Unknown camera error")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("camera.error.permissionDenied.recovery", value: "Open Settings and enable camera access for this app.", comment: "Recovery suggestion for permission denied")
        case .permissionRestricted:
            return NSLocalizedString("camera.error.permissionRestricted.recovery", value: "Contact your device administrator to allow camera access.", comment: "Recovery suggestion for permission restricted")
        case .hardwareUnavailable:
            return NSLocalizedString("camera.error.hardwareUnavailable.recovery", value: "This feature requires a camera.", comment: "Recovery suggestion for hardware unavailable")
        case .sessionSetupFailed:
            return NSLocalizedString("camera.error.sessionSetupFailed.recovery", value: "Try restarting the app.", comment: "Recovery suggestion for session setup failed")
        case .sessionStartFailed:
            return NSLocalizedString("camera.error.sessionStartFailed.recovery", value: "Try again or restart the app.", comment: "Recovery suggestion for session start failed")
        case .captureFailed:
            return NSLocalizedString("camera.error.captureFailed.recovery", value: "Try capturing the photo again.", comment: "Recovery suggestion for capture failed")
        case .unknown:
            return NSLocalizedString("camera.error.unknown.recovery", value: "Try restarting the app.", comment: "Recovery suggestion for unknown error")
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