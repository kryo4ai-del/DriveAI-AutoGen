enum ExamConfig {
    static let passThreshold: Double = 75.0
    static let totalQuestions: Int = 30
    static let timeLimit: TimeInterval = 30 * 60
}

var passed: Bool {
    percentage >= ExamConfig.passThreshold
}