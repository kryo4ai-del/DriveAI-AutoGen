import Foundation

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

    public init(
        id: String,
        userId: String,
        startedAt: Date,
        completedAt: Date,
        score: Int,
        maxScore: Int,
        percentage: Double,
        passed: Bool,
        timeTakenSeconds: Int,
        duration: TimeInterval
    ) {
        self.id = id
        self.userId = userId
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.score = score
        self.maxScore = maxScore
        self.percentage = percentage
        self.passed = passed
        self.timeTakenSeconds = timeTakenSeconds
        self.duration = duration
    }
}