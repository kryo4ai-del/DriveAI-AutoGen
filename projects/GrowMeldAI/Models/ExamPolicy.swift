enum ExamPolicy: Sendable {
    static let passingScorePercentage = 75
}

// In init:
self.passed = score >= ExamPolicy.passingScorePercentage