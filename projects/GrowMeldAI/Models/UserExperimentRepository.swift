// ❌ NO CONSENT CHECK
protocol UserExperimentRepository {
    func assignVariant(
        userID: String,
        experimentID: String
    ) async -> Result<(UserExperiment, Variant), DomainError>
    // No parameter: consentGiven: Bool
}