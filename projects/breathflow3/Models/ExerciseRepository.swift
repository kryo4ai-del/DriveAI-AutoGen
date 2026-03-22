// Models/ExerciseRepository.swift
import Foundation

actor ExerciseRepository: ExerciseRepositoryProtocol {
    private var cachedExercises: [Exercise]?
    private var loadTask: Task<[Exercise], Error>?

    nonisolated private func loadJSON() throws -> Data {
        guard let url = Bundle.main.url(forResource: "ExerciseData", withExtension: "json") else {
            throw AppError.notFound
        }
        return try Data(contentsOf: url)
    }

    func loadExercises() async throws -> [Exercise] {
        // Return cached if available
        if let cached = cachedExercises {
            return cached
        }

        // Prevent concurrent loads - reuse in-flight task
        if let task = loadTask {
            return try await task.value
        }

        let task = Task {
            try await performLoad()
        }

        self.loadTask = task
        let result = try await task.value
        self.loadTask = nil
        return result
    }

    private func performLoad() async throws -> [Exercise] {
        let data = try loadJSON()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exercises = try decoder.decode([Exercise].self, from: data)
        self.cachedExercises = exercises
        return exercises
    }

    func getExercise(by id: UUID) async throws -> Exercise {
        let exercises = try await loadExercises()
        guard let exercise = exercises.first(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        return exercise
    }

    func getExercises(by category: ExerciseCategory) async throws -> [Exercise] {
        let exercises = try await loadExercises()
        return exercises.filter { $0.category == category }
    }
}
