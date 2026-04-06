// Add to UserSubscription.swift
public struct UserSubscription: Identifiable, Codable, Equatable {
    // ... existing fields ...
    
    // GDPR + Compliance Audit Trail
    public let autoRenewalConsentDate: Date?
    public let autoRenewalConsentVersion: String?  // Hash of T&Cs accepted
    public let autoRenewalConsentIpAddress: String?  // For dispute resolution
    
    public let cancellationInitiatedDate: Date?
    public let cancellationMethod: CancellationMethod?  // .inApp, .appStore, .support
    
    public let lastChargebackDate: Date?  // For fraud detection
    public let trialConversionDate: Date?  // When trial → paid
    
    public enum CancellationMethod: String, Codable {
        case inApp
        case appStoreSettings
        case emailSupport
        case unknown
    }
}

// Add to SubscriptionProduct.swift

// New file: SubscriptionCompliance.swift
public struct ConsentAuditTrail: Codable {
    public let userId: String
    public let consentType: ConsentType
    public let givenAt: Date
    public let tAndCsVersionHash: String  // SHA-256 hash
    public let ipAddress: String?
    public let userAgent: String?  // Device/OS info
    
    public enum ConsentType: String, Codable {
        case autoRenewal
        case marketing
        case dataProcessing
    }
}
