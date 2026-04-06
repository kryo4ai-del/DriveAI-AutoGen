// MARK: - ASA Compliance Manager
import Foundation

/// Protocol for ASA compliance management
protocol ASAComplianceManagerProtocol {
    func canTrackEvent(_ event: ASAEventType) -> Bool
    func canShowASA() -> Bool
    func getConsentStatus() -> ASAConsentStatus
}

/// Consent status for ASA tracking
enum ASAConsentStatus {
    case granted
    case denied
    case notDetermined
}

/// Compliance manager implementation