import Foundation

/// Defines the purpose for camera access with GDPR-compliant context
enum CameraUseCase: String, CaseIterable, Sendable {
    case profileAvatar          // User consent – optional profile photo
    case documentScanning       // Consent + legitimate interest – ID/license
    case identityVerification   // Consent + contractual – age verification
    case arVisualization        // Consent – AR traffic scenarios

    var description: String {
        switch self {
        case .profileAvatar:
            return "Profile photo for your learning progress"
        case .documentScanning:
            return "Scan your driver's license to verify eligibility"
        case .identityVerification:
            return "Verify your age for age-restricted content"
        case .arVisualization:
            return "Interactive AR scenarios for better learning"
        }
    }

    var dataRetentionDays: Int {
        switch self {
        case .profileAvatar: return 365
        case .documentScanning: return 30
        case .identityVerification: return 7
        case .arVisualization: return 1
        }
    }

    var privacyNoticeVersion: String {
        "1.0" // Should be synchronized with your privacy policy
    }
}