import Foundation

enum MetaAdsError: LocalizedError {
    case consentNotGranted
    case initializationFailed(String)
    case eventTrackingFailed(String)
    case sdkNotInitialized
    
    var errorDescription: String? {
        switch self {
        case .consentNotGranted:
            return "Meta Ads SDK cannot initialize without user consent"
        case .initializationFailed(let msg):
            return "Meta SDK initialization failed: \(msg)"
        case .eventTrackingFailed(let msg):
            return "Event tracking failed: \(msg)"
        case .sdkNotInitialized:
            return "SDK not initialized. Ensure consent was granted."
        }
    }
}