// ❌ SelectExerciseUseCase duplicates logic from FetchExercisesUseCase
final class SelectExerciseUseCase: Sendable {
    func execute(exerciseId: UUID) async throws -> ExerciseSelection {
        let exercise = try await repository.fetchExercise(id: exerciseId)
        let performance = try await repository.fetchPerformance(exerciseId: exerciseId)
        let readiness = calculateReadiness.execute(exercise: exercise, performance: performance)
        // ...
    }
}