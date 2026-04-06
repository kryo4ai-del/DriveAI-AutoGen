public struct ExamAttempt {
    public let id: String
    public let userId: String
    public let startedAt: Date
    public let completedAt: Date
    public let score: Int
    public let maxScore: Int
    public let percentage: Double
    public let passed: Bool
    public let timeTakenSeconds: Int
    public let duration: TimeInterval

    public var actualDuration: TimeInterval {
        completedAt.timeIntervalSince(startedAt)
    }
}