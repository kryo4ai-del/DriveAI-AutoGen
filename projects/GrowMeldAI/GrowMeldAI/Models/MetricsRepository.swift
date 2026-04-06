protocol MetricsRepository {
    /// Retrieve all metrics associated with a user (GDPR Article 15)
    func getUserMetrics(userID: String) async -> Result<[ExperimentMetric], DomainError>
    
    /// Retrieve user's experiment assignments (GDPR Article 15)
    func getUserExperimentAssignments(userID: String) async -> Result<[UserExperiment], DomainError>
    
    /// Export user's data in portable format (GDPR Article 20)
    func exportUserData(userID: String) async -> Result<Data, DomainError>  // JSON or CSV
}