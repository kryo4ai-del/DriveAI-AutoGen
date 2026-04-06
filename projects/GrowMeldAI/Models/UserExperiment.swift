public struct UserExperiment {
    // ... existing fields ...
    public let userAgeVerified: Bool  // Has user's age been verified?
    public let requiresParentalConsent: Bool  // Under 16?
    public let parentalConsentGivenAt: Date?  // When consent was given
    
    public var canParticipateInTest: Bool {
        if requiresParentalConsent {
            return parentalConsentGivenAt != nil
        }
        return true
    }
}