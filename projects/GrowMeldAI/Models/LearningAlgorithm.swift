// Services/Domain/LearningAlgorithm.swift
import Foundation
struct LearningAlgorithm {
    /// Calculates next review date respecting user's local midnight.
    ///
    /// - Parameters:
    ///   - lastAttemptDate: Date question was answered
    ///   - correctCount: Number of correct answers
    ///   - attemptCount: Total attempts
    ///   - calendar: User's calendar (defaults to current, respects timezone)
    /// - Returns: Next review date at user's local midnight
    static func calculateNextReviewDate(
        lastAttemptDate: Date,
        correctCount: Int,
        attemptCount: Int,
        calendar: Calendar = .current
    ) -> Date {
        guard attemptCount > 0, correctCount > 0 else {
            return calendar.date(byAdding: .day, value: 1, to: lastAttemptDate) ?? lastAttemptDate
        }
        
        let accuracy = Double(correctCount) / Double(attemptCount)
        
        // If accuracy < 60%, review in 1 day
        if accuracy < 0.6 {
            return calendar.date(byAdding: .day, value: 1, to: lastAttemptDate) ?? lastAttemptDate
        }
        
        let intervalDays: Int
        switch attemptCount {
        case 1: intervalDays = 1
        case 2: intervalDays = 3
        case 3: intervalDays = 7
        case 4: intervalDays = 14
        case 5...: intervalDays = 30
        default: intervalDays = 1
        }
        
        // ✅ Start from user's local midnight, then add days
        let startOfDay = calendar.startOfDay(for: lastAttemptDate)
        return calendar.date(byAdding: .day, value: intervalDays, to: startOfDay) ?? lastAttemptDate
    }
}