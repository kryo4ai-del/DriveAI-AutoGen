// Models/ExerciseSelectionUseCase.swift
import Foundation

@MainActor
final class ExerciseSelectionUseCase: ExerciseSelectionUseCaseProtocol {
    private let repository: ExerciseRepository
    private let calculateReadiness: CalculateReadinessUseCase

    init(repository: ExerciseRepository, calculateReadiness: CalculateReadinessUseCase = CalculateReadinessUseCase()) {
        self.repository = repository
        self.calculateReadiness = calculateReadiness
    }

    func fetchExercises() async throws -> [Exercise] {
        return try await repository.loadExercises()
    }

    func getRecommendedExercises(from exercises: [Exercise]) async -> [Exercise] {
        // Return exercises sorted by difficulty for recommendation
        return exercises.sorted { $0.questionCount > $1.questionCount }
    }

    func selectExercise(_ exercise: Exercise) async throws {
        // Selection logic - could persist selection state
        _ = try await repository.getExercise(by: exercise.id)
    }
}
