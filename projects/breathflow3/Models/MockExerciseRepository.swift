// Models/MockExerciseRepository.swift
import Foundation

final class MockExerciseRepository: ExerciseRepositoryProtocol, @unchecked Sendable {
    let exerciseCount: Int
    let shouldFail: Bool
    let failureError: RepositoryError

    init(exerciseCount: Int = 50, shouldFail: Bool = false, failureError: RepositoryError = .networkUnavailable) {
        self.exerciseCount = exerciseCount
        self.shouldFail = shouldFail
        self.failureError = failureError
    }

    func loadExercises() async throws -> [Exercise] {
        if shouldFail {
            throw failureError
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        let categories = ExerciseCategory.allCases
        let difficulties = ExerciseDifficulty.allCases

        return (0..<exerciseCount).map { index in
            Exercise(
                id: UUID(),
                name: "Exercise \(index + 1)",
                description: "Description for exercise \(index + 1)",
                category: categories[index % categories.count],
                difficulty: difficulties[index % difficulties.count],
                estimatedDuration: (index % 3 + 1) * 5,
                questionCount: (index % 4 + 1) * 5,
                icon: "circle.fill",
                color: "blue"
            )
        }
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
