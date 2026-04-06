public struct ExamAttempt: ... {
    let score: Int
    let maxScore: Int
    let passed: Bool
    let timeTakenSeconds: Int

    public let id: String
    public let userId: String
    public let startedAt: Date      // ✅ When exam started
    public let completedAt: Date    // ✅ When submitted
    public let score: Int
    public let percentage: Double
    public let duration: TimeInterval  // Computed: completedAt - startedAt
    // ... rest
    
    public var actualDuration: TimeInterval {
        completedAt.timeIntervalSince(startedAt)
    }
}