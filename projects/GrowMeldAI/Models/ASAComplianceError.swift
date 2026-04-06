import Foundation

/// Centralized compliance checker for Apple Search Ads campaigns
/// Ensures GDPR, UWG (German Unfair Competition Act), and Apple ASA policy compliance
enum ASAComplianceError: Error, LocalizedError {
    case missingDPA(String)
    case invalidClaimSubstantiation
    case missingPrivacyPolicy
    case appleASAPolicyViolation(String)
    case uwgNonCompliance(String)

    var errorDescription: String? {
        switch self {
        case .missingDPA(let processor):
            return "Missing DPA with \(processor). Required for GDPR compliance."
        case .invalidClaimSubstantiation:
            return "Ad claims lack proper substantiation. All performance claims must be verified."
        case .missingPrivacyPolicy:
            return "Privacy policy must include data retention periods and user rights."
        case .appleASAPolicyViolation(let reason):
            return "Apple Search Ads policy violation: \(reason)"
        case .uwgNonCompliance(let reason):
            return "German UWG violation: \(reason)"
        }
    }
}

struct ASAComplianceChecker {
    private let privacyPolicyURL: URL
    private let dpas: [String: URL]
    private let substantiationSources: [String: URL]

    init(privacyPolicyURL: URL,
         dpas: [String: URL],
         substantiationSources: [String: URL]) {
        self.privacyPolicyURL = privacyPolicyURL
        self.dpas = dpas
        self.substantiationSources = substantiationSources
    }

    /// Validates all compliance requirements for ASA campaign launch
    func validateCampaign(copyVariants: [ASACopyVariant],
                         targeting: ASATargetingParams) throws {
        try validateDPAs()
        try validatePrivacyPolicy()
        try validateClaims(copyVariants: copyVariants)
        try validateTargeting(targeting)
        try validateAppleASAPolicy(copyVariants: copyVariants)
    }

    private func validateDPAs() throws {
        let requiredProcessors = ["Firebase", "AppsFlyer", "Apple"]
        for processor in requiredProcessors {
            guard dpas[processor] != nil else {
                throw ASAComplianceError.missingDPA(processor)
            }
        }
    }

    private func validatePrivacyPolicy() throws {
        // Check privacy policy contains required sections
        let requiredSections = ["dataRetention", "userRights", "thirdPartySharing"]
        let policyContent = try String(contentsOf: privacyPolicyURL)
        let missingSections = requiredSections.filter { !policyContent.contains($0) }

        if !missingSections.isEmpty {
            throw ASAComplianceError.missingPrivacyPolicy
        }
    }

    private func validateClaims(copyVariants: [ASACopyVariant]) throws {
        let claimPattern = #"(\d+(\.\d+)?)\s*(K|M|%)?\s*(users|install|pass rate)"#
        let regex = try NSRegularExpression(pattern: claimPattern)

        for variant in copyVariants {
            let range = NSRange(location: 0, length: variant.text.utf16.count)
            let matches = regex.matches(in: variant.text, range: range)

            for match in matches {
                let claim = (variant.text as NSString).substring(with: match.range)
                guard substantiationSources[claim] != nil else {
                    throw ASAComplianceError.invalidClaimSubstantiation
                }
            }
        }
    }

    private func validateTargeting(_ targeting: ASATargetingParams) throws {
        // Validate geo targeting complies with German law
        let germanStates = ["Baden-Württemberg", "Bayern", "Berlin", "Brandenburg"]
        let invalidStates = targeting.geoTargeting.filter { !germanStates.contains($0) }

        if !invalidStates.isEmpty {
            throw ASAComplianceError.uwgNonCompliance(
                "Targeting non-German states: \(invalidStates.joined(separator: ", "))"
            )
        }
    }

    private func validateAppleASAPolicy(copyVariants: [ASACopyVariant]) throws {
        for variant in copyVariants {
            if variant.text.contains("official") && !variant.text.contains("not affiliated") {
                throw ASAComplianceError.appleASAPolicyViolation(
                    "Must include disclaimer when using 'official' in educational context"
                )
            }
        }
    }
}