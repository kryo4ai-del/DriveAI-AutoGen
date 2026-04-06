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

// Struct AdFeedback declared in Models/AdFeedback.swift

// MARK: - Ad Service Protocol (mockable, testable)

// MARK: - Concrete Implementation