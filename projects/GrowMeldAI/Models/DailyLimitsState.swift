// Domain/Freemium/Models/DailyLimitsState.swift
public struct DailyLimitsState: Codable, Equatable, Sendable {
    // ... existing code ...
    
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