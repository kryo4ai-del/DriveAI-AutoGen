final class MockExerciseRepository: ExerciseRepositoryProtocol {
    let exerciseCount: Int
    let shouldFail: Bool
    
    init(exerciseCount: Int = 50, shouldFail: Bool = false) {
        self.exerciseCount = exerciseCount
        self.shouldFail = shouldFail
    }
    
    func fetchAllExercises() async throws -> [Exercise] {
        if shouldFail {
            throw RepositoryError.networkUnavailable
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return (0..<exerciseCount).map { index in
            Exercise(
                id: "ex_\(String(format: "%03d", index))",
                name: "Exercise \(index + 1)",
                readiness: [.stillShaky, .buildingConfidence, .testReady].randomElement()!,
                // ... other fields ...
            )
        }
    }
}