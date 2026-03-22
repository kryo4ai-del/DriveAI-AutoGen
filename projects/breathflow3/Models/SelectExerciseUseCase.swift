// Models/SelectExerciseUseCase.swift
import Foundation

final class SelectExerciseUseCase: Sendable {
    private let repository: ExerciseRepository
    private let calculateReadiness: CalculateReadinessUseCase

    init(repository: ExerciseRepository, calculateReadiness: CalculateReadinessUseCase = CalculateReadinessUseCase()) {
        self.repository = repository
        self.calculateReadiness = calculateReadiness
    }

    func execute(exerciseId: UUID) async throws -> ExerciseSelection {
        let exercise = try await repository.getExercise(by: exerciseId)
        let readiness = calculateReadiness.execute(exercise: exercise, performance: nil)
        return ExerciseSelection(
            exercise: exercise,
            performance: nil,
            readiness: readiness
        )
    }
}
