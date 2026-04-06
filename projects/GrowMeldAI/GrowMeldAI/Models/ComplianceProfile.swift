// Models/Compliance/ComplianceProfile.swift

struct ComplianceProfile: Codable, Equatable {
    enum AgeGroup: String, Codable {
        case unknown               // Pre-verification
        case child                 // Under 13 (U.S.) or under 16 (EU)
        case adult                 // 13+ (U.S.) or 16+ (EU)
    }
    
    enum Jurisdiction: String, Codable {
        case eu                    // GDPR/DSGVO applies
        case us                    // COPPA applies (if child)
        case other                 // Neither applies
        case unknown               // Not yet determined
    }
    
    let ageGroup: AgeGroup
    let jurisdiction: Jurisdiction
    let verificationDate: Date
    let hasParentalConsent: Bool   // COPPA: verifiable parental consent
    
    // MARK: - Computed Compliance Rules
    
    var requiresParentalConsent: Bool {
        ageGroup == .child && jurisdiction == .us
    }
    
    var canCollectBehavioralData: Bool {
        // COPPA blocks behavioral data for under-13 U.S. users
        !(ageGroup == .child && jurisdiction == .us)
    }
    
    var canUseTargetedAdvertising: Bool {
        // COPPA blocks targeted ads for under-13 U.S. users
        !(ageGroup == .child && jurisdiction == .us)
    }
    
    var dataRetentionDays: Int {
        switch (ageGroup, jurisdiction) {
        case (.child, .us):        return 30   // COPPA: minimal retention
        case (.child, .eu):        return 90   // GDPR: data minimization
        case (.adult, .eu):        return 365  // Standard EU retention
        case (.adult, .us):        return 365  // Standard U.S. retention
        default:                   return 0    // No collection if unverified
        }
    }
    
    var isCompliant: Bool {
        ageGroup != .unknown &&
        jurisdiction != .unknown &&
        (ageGroup == .adult || hasParentalConsent)
    }
}