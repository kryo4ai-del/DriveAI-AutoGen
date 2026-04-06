struct RegionConfigAudit {
    let version: String
    let updated: Date
    let validatedBy: [String] // ["RTA Australia", "ICBC BC", ...]
    let signature: String? // For tamper detection (future)
}