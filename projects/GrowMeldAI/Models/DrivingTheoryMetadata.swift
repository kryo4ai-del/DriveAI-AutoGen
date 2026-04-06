enum LegalSeverity: String, Codable {
    case low
    case medium
    case high
}

struct DrivingTheoryMetadata: Codable {
    let stvoSection: String?
    let trafficSignNumber: String?
    let legalExplanation: String
    // ✅ Good: Severity system drives UI decisions
    let severity: LegalSeverity
}