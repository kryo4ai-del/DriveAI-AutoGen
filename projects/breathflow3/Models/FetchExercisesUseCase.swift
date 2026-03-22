// Models/FetchExercisesUseCase.swift
import Foundation

@MainActor
final class FetchExercisesUseCase {
    private let repository: ExerciseRepository

    init(repository: ExerciseRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Exercise] {
        return try await repository.loadExercises()
    }
}
