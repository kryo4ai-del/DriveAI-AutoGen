import Foundation
final class DefaultExerciseDataProvider: ExerciseDataProvider {
    static let shared = DefaultExerciseDataProvider()
    
    private static let mockExercises = DefaultExerciseDataProvider.buildMockData()
    
    private static func buildMockData() -> [BreathingExercise] {
        [
            .boxBreathing,
            .fourSevenEight
        ]
    }
    
    func fetchExercises() async throws -> [BreathingExercise] {
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network
        return Self.mockExercises
    }
}