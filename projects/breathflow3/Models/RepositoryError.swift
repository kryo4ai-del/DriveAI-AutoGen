enum RepositoryError: LocalizedError {
    case networkUnavailable
    case invalidResponse
    case decodingError(String)
    case serverError(Int)
    case timeout
  }
  
  protocol ExerciseRepositoryProtocol {
    func fetchAllExercises() async throws(RepositoryError) -> [Exercise]
    func trackExerciseSelection(exerciseId: String) async throws(RepositoryError)
  }