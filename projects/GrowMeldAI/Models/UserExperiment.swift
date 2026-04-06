import Foundation

public struct UserExperiment {
    public let userAgeVerified: Bool
    public let requiresParentalConsent: Bool
    public let parentalConsentGivenAt: Date?

    public init(userAgeVerified: Bool, requiresParentalConsent: Bool, parentalConsentGivenAt: Date?) {
        self.userAgeVerified = userAgeVerified
        self.requiresParentalConsent = requiresParentalConsent
        self.parentalConsentGivenAt = parentalConsentGivenAt
    }

    public var canParticipateInTest: Bool {
        if requiresParentalConsent {
            return parentalConsentGivenAt != nil
        }
        return true
    }
}