struct ExercisePerformance: Codable, Sendable, Equatable {
    let exerciseId: UUID
    let completionCount: Int
    let bestScore: Double        // 0-100
    let averageScore: Double     // 0-100
    let lastAttemptDate: Date?
    let totalTimeSpent: TimeInterval
    let createdAt: Date
    let updatedAt: Date
    
    // THROWING INITIALIZER - Validates all inputs
    init(
        exerciseId: UUID,
        completionCount: Int,
        bestScore: Double,
        averageScore: Double,
        lastAttemptDate: Date? = nil,
        totalTimeSpent: TimeInterval = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) throws { /* validation */ }
    
    var scorePercentage: Double { /* clamped 0-100 */ }
    var averageScorePercentage: Double { /* clamped 0-100 */ }
}