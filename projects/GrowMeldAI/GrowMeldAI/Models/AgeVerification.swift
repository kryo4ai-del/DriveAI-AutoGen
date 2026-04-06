struct AgeVerification {
    let userId: UUID
    let verifiedAge: Int?              // Null if unverified
    let verificationMethod: Method     // selfReport | document | parental
    let verificationDate: Date
    let isParentalConsentActive: Bool
    
    enum Method {
        case selfReport              // "I am 16+"
        case documentVerification    // ID scan (future MVP+)
        case parentalConsentGranted  // Parent confirmed child <13
    }
}

// Immutable. Persisted in secure enclave or Keychain.
// Change only via ComplianceService.updateAgeVerification()