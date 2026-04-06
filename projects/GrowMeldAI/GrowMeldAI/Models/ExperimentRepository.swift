public protocol ExperimentRepository: AnyObject {
    func getExperiment(by id: String) async -> Result<Experiment, DomainError>
    func getExperiments(status: ExperimentStatus) async -> Result<[Experiment], DomainError>
    // Remove: func getActiveExperiments() — use getExperiments(status: .active)
    
    func createExperiment(_ experiment: Experiment) async -> Result<String, DomainError>
    func updateExperiment(_ experiment: Experiment) async -> Result<Void, DomainError>
    func updateExperimentStatus(_ experimentID: String, _ status: ExperimentStatus) async -> Result<Void, DomainError>
    func deleteExperiment(by id: String) async -> Result<Void, DomainError>
}