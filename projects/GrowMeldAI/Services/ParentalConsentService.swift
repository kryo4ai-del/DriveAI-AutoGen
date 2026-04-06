struct ParentalConsentService {
    
    private let keychainService: KeychainService
    private let backendClient: BackendClient  // Stub for MVP
    
    func requestParentalConsent(childId: UUID, parentEmail: String) async throws -> UUID {
        // 1. Validate email
        // 2. Generate secure token
        // 3. Create ParentalConsentRequest with 30-day expiry
        // 4. Call backend: POST /coppa/parental-consent-request
        // 5. Persist locally
        // 6. Return requestId
    }
    
    func pollConsentStatus(requestId: UUID) async throws -> ParentalConsentState {
        // Call backend: GET /coppa/parental-consent-request/{requestId}/status
        // Update local state
    }
    
    func markConsentApproved(requestId: UUID) -> ParentalConsentRequest {
        // Triggered by backend notification or polling
        // Updates state to .consentGranted
    }
    
    func isConsentExpired(requestId: UUID) -> Bool {
        // Returns true if request.expiryDate < now
    }
}