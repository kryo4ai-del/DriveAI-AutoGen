// MARK: - Models
import Foundation

struct AdConsent {
    let id: String
    let isGranted: Bool
    let timestamp: Date
    let source: ConsentSource
    
    enum ConsentSource {
        case onboarding
        case settingsScreen
        case deferredPrompt
    }
}

struct AdFeedback {
    let questionsReviewedCount: Int
    let confidenceIncreasePercent: Double
    let campaignId: String
}

// MARK: - Ad Service Protocol (mockable, testable)

// MARK: - Concrete Implementation