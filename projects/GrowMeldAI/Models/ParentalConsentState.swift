import Foundation
enum ParentalConsentState {
    case notApplicable           // Age verified ≥13
    case consentPending          // Waiting for parent approval
    case consentGranted          // Parent approved; app usable
    case consentDenied           // Parent refused; app locked
    case consentExpired          // Renewal required
}

struct ParentalConsentRequest {
    let childId: UUID
    let parentEmail: String      // Where consent link sent
    let requestDate: Date
    let expiryDate: Date         // 30 days to respond (COPPA best practice)
    let token: String            // Secure token for parent verification
    let state: ParentalConsentState
}