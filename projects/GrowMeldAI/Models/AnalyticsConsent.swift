import Foundation

/// Represents user consent status for analytics tracking
enum AnalyticsConsent: String, Codable, Equatable {
    case granted
    case denied
    case notDetermined

    var isGranted: Bool {
        self == .granted
    }
}

/// Encapsulates the state of analytics consent including versioning
struct AnalyticsConsentState: Codable, Equatable {
    var consent: AnalyticsConsent
    var lastUpdated: Date
    var consentVersion: String

    init(consent: AnalyticsConsent = .notDetermined,
         consentVersion: String = "1.0") {
        self.consent = consent
        self.lastUpdated = Date()
        self.consentVersion = consentVersion
    }
}