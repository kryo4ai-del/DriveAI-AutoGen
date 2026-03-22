@MainActor  // ← BUG #3 FIX: Was missing, caused thread-safety issues
protocol ExerciseRepository: Sendable {
    
    /// Fetch all exercises, optionally filtered by category
    /// - Parameter category: Optional filter; nil returns all categories
    /// - Returns: Array of Exercise sorted by difficulty
    /// - Throws: .networkFailure, .cachingFailure, .decodingFailure
    func fetchExercises(category: ExerciseCategory?) async throws -> [Exercise]
    
    /// Fetch single exercise by ID
    /// - Parameter id: Exercise UUID
    /// - Returns: Exercise matching ID
    /// - Throws: .exerciseNotFound(id), .networkFailure, .decodingFailure
    func fetchExercise(id: UUID) async throws -> Exercise
    
    /// Fetch performance data for specific exercise
    /// - Parameter exerciseId: Exercise UUID
    /// - Returns: ExercisePerformance or nil if not started
    /// - Throws: .performanceDataMissing, .decodingFailure
    func fetchPerformance(exerciseId: UUID) async throws -> ExercisePerformance?
    
    /// Fetch all performance records
    /// - Returns: Array of all ExercisePerformance records
    /// - Throws: .networkFailure, .decodingFailure
    func fetchAllPerformance() async throws -> [ExercisePerformance]
    
    /// Save or update performance record
    /// - Parameter performance: Valid ExercisePerformance (validated by model)
    /// - Throws: .cachingFailure, .concurrencyError
    func savePerformance(_ performance: ExercisePerformance) async throws
    
    /// Delete performance record
    /// - Parameter exerciseId: Exercise UUID to delete
    /// - Throws: .cachingFailure
    func deletePerformance(exerciseId: UUID) async throws
}