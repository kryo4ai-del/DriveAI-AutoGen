
enum ComplianceError: LocalizedError {
    case userUnder16
    case parentalConsentRequired
    case parentalConsentExpired
    case invalidEmailFormat
    case backendUnavailable
}