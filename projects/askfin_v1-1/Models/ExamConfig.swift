enum ExamConfig {
    static let totalQuestions = 30
    static let passingThreshold = 24 // 80%
    static let timeLimit: TimeInterval = 3600 // 60 min
}

// Use:
// [FK-019 sanitized] session.passed = score >= ExamConfig.passingThreshold