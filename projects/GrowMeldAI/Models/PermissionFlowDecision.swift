import Foundation

/// Represents the result of a camera permission request.
/// Used to drive UI state transitions in the onboarding flow.
enum PermissionFlowDecision: Equatable {
    /// User granted camera access
    case grantedCamera
    /// User explicitly denied camera access
    case denied
    /// User hasn't been asked yet (system will prompt)
    case notDetermined
    /// Camera access restricted by device policies (MDM, parental controls)
    case restricted

    var isGranted: Bool {
        self == .grantedCamera
    }

    var userFacingMessage: String {
        switch self {
        case .grantedCamera: return "Kamerazugriff gewährt"
        case .denied: return "Kamerazugriff verweigert"
        case .notDetermined: return "Berechtigung wird angefordert..."
        case .restricted: return "Kamerazugriff eingeschränkt"
        }
    }
}