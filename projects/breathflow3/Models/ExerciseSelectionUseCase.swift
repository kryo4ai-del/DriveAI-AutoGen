@MainActor
final class ExerciseSelectionUseCase: Sendable {
    private let repository: ExerciseRepository
    
    func getExercises(category: ExerciseCategory? = nil) async throws -> [ExerciseSelection]
    func getExercise(id: UUID) async throws -> ExerciseSelection
    func getRecommended() async throws -> [ExerciseSelection]
}