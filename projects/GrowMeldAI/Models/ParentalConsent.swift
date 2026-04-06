// Models/Domain/ParentalConsent.swift
struct ParentalConsent: Codable, Identifiable {
    let id: String
    let userId: String
    let guardianEmail: String
    let guardianVerificationToken: String?
    let consentGivenAt: Date?
    let expiresAt: Date?  // Consent validity
    let status: ConsentStatus
    
    enum ConsentStatus: String, Codable {
        case pending           // Waiting for guardian email
        case awaitingVerification  // Verification email sent
        case verified          // Guardian verified, consent granted
        case rejected          // Guardian denied
        case expired           // Consent expired (annual renewal)
    }
}

// Services/Remote/ParentalConsentService.swift

enum ParentalConsentError: LocalizedError {
    case invalidToken
    case consentExpired
    case alreadyVerified
    
    var errorDescription: String? {
        switch self {
        case .invalidToken: return "Ungültiger Verifikationslink"
        case .consentExpired: return "Einwilligung abgelaufen"
        case .alreadyVerified: return "Bereits verifiziert"
        }
    }
}

// ViewModel for Signup
@MainActor