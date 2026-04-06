public struct DailyLimitsState: Codable, Equatable, Sendable {
    public var questionsAnsweredToday: Int
    public var examAttemptsUsedToday: Int
    
    public init(questionsAnsweredToday: Int = 0, examAttemptsUsedToday: Int = 0) {
        self.questionsAnsweredToday = questionsAnsweredToday
        self.examAttemptsUsedToday = examAttemptsUsedToday
    }
    
    private func calculateRemaining(answered: Int, limit: Int) -> Int {
        max(0, limit - answered)
    }
    
    public var remainingQuestions: Int {
        calculateRemaining(
            answered: questionsAnsweredToday,
            limit: DailyLimits.defaults.questionsPerDay
        )
    }
    
    public var remainingExamAttempts: Int {
        calculateRemaining(
            answered: examAttemptsUsedToday,
            limit: DailyLimits.defaults.examAttemptsPerDay
        )
    }
}