// Models/ExerciseRepositoryProtocol.swift
import Foundation

protocol ExerciseRepositoryProtocol: Sendable {
    func loadExercises() async throws -> [Exercise]
    func getExercise(by id: UUID) async throws -> Exercise
    func getExercises(by category: ExerciseCategory) async throws -> [Exercise]
}
