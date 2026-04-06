// ❌ NO CONSENT CHECK
protocol UserExperimentRepository {
    func assignVaria(
        userID: String,
        experimentID: String
    ) async -> Result<(UserExperiment, Variant), DomainError>
    // No parameter: consentGiven: Bool
}