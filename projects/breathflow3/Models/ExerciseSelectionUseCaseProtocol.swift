// MARK: - Domain/ExerciseSelectionUseCase.swift
import Foundation

protocol ExerciseSelectionUseCaseProtocol {
    func fetchExercises() async throws -> [Exercise]
    func getRecommendedExercises(from exercises: [Exercise]) async -> [Exercise]
    func selectExercise(_ exercise: Exercise) async throws
}

@MainActor