import Foundation
final class DefaultExerciseDataProvider: ExerciseDataProvider {
    static let shared = DefaultExerciseDataProvider()
    
    private static let mockExercises = Self.buildMockData()
    
    private static func buildMockData() -> [BreathingExercise] {
        [
            BreathingExercise(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
                // ...
            )
        ]
    }
    
    func fetchExercises() async throws -> [BreathingExercise] {
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network
        return Self.mockExercises
    }
}