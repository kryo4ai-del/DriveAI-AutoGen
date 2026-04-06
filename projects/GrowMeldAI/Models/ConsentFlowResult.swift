enum ConsentFlowResult {
    case approved(ConsentRecord)
    case requiresParentalConsent(childID: UUID)
    case parentalConsented(parentConsentRecord: ConsentRecord)
    case rejected
}

func handleUnderage(_ birthDate: Date, region: ComplianceRegion) -> ConsentFlowResult {
    guard region == .unitedStates else {
        return .rejected // EU users simply can't use app
    }
    
    // US COPPA: require parental consent
    let childID = UUID()
    return .requiresParentalConsent(childID: childID)
}