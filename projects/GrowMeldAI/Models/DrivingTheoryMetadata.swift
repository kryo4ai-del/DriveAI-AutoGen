struct DrivingTheoryMetadata: Codable {
    let stvoSection: String?
    let trafficSignNumber: String?
    let legalExplanation: String
    // ✅ Good: Severity system drives UI decisions
    let severity: LegalSeverity
}