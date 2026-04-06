protocol DataBackend {
    func syncProgress(category: String) async throws
    func fetchStatistics() async throws -> UserStatistics
    func uploadAttempt(_ attempt: QuestionAttempt) async throws
    func getAvailableBackends() -> [BackendType]
  }
  
  // Implementations:
  // - LocalDataService (SQLite/JSON)
  // - FirebaseDataService
  // - Future: GraphQL, REST API