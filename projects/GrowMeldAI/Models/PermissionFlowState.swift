import Foundation

enum PermissionFlowState: Equatable {
    case initial
    case requestingPermission
    case permissionGranted
    case permissionDenied(reason: String)
    case capturingPhoto
    case photoReady(imageData: Data)
    case previewingPhoto(imageData: Data)
    case completed
    case error(PermissionFlowError)
    
    // MARK: - Transition Validation
    func canTransitionTo(_ next: PermissionFlowState) -> Bool {
        switch (self, next) {
        case (.initial, .requestingPermission): return true
        case (.requestingPermission, .permissionGranted): return true
        case (.requestingPermission, .permissionDenied): return true
        case (.permissionGranted, .capturingPhoto): return true
        case (.capturingPhoto, .photoReady): return true
        case (.photoReady, .previewingPhoto): return true
        case (.previewingPhoto, .completed): return true
        case (.initial, .permissionDenied): return true
        case (_, .error): return true
        case (_, .initial): return true
        default: return false
        }
    }
    
    // MARK: - State Properties
    var canProceedToCapture: Bool {
        if case .permissionGranted = self { return true }
        return false
    }
    
    var canRetry: Bool {
        switch self {
        case .permissionDenied, .error:
            return true
        default:
            return false
        }
    }
    
    var stepNumber: Int {
        switch self {
        case .initial: return 0
        case .requestingPermission: return 1
        case .permissionGranted: return 2
        case .capturingPhoto: return 3
        case .photoReady: return 4
        case .previewingPhoto: return 4
        case .completed: return 5
        case .error, .permissionDenied: return 0
        }
    }
}

enum PermissionFlowError: LocalizedError, Equatable {
    case permissionDenied
    case captureFailure(String)
    case invalidTransition(from: String, to: String)
    case cameraUnavailable
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return String(localized: "error.flow.permission_denied", bundle: .module)
        case .captureFailure(let reason):
            return reason
        case .invalidTransition:
            return String(localized: "error.flow.invalid_transition", bundle: .module)
        case .cameraUnavailable:
            return String(localized: "error.camera.unavailable", bundle: .module)
        }
    }
    
    var recoveryAction: String? {
        switch self {
        case .permissionDenied:
            return String(localized: "action.open_settings", bundle: .module)
        default:
            return String(localized: "action.retry", bundle: .module)
        }
    }
}