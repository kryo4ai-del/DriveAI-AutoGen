final class ResultsPersistenceService {
    func load() throws -> [SimulationResult]
    func save(_ results: [SimulationResult]) throws
}