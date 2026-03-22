@MainActor
final class FetchExercisesUseCase {  // ← NO Sendable
    private let repository: ExerciseRepository
    func execute(...) async throws -> [Exercise]
}