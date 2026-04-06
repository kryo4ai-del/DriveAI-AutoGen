import Foundation

// MARK: - Core Trial Models

struct TrialQuota {
    let dailyLimit: Int = 5
    let questionsAnsweredToday: Int
    let lastResetDate: Date
    
    var remainingToday: Int {
        max(0, dailyLimit - questionsAnsweredToday)
    }
    
    var isExhausted: Bool {
        questionsAnsweredToday >= dailyLimit
    }
    
    var resetTime: Date {
        Calendar.current.startOfDay(for: lastResetDate).addingTimeInterval(86400) // +1 day
    }
    
    var timeUntilReset: TimeInterval {
        max(0, resetTime.timeIntervalSinceNow)
    }
    
    var accessibilityLabel: String {
        String(format: NSLocalizedString(
            "trial_quota_label",
            value: "Today: %d of %d questions answered",
            comment: "VoiceOver label for daily quota"
        ), questionsAnsweredToday, dailyLimit)
    }
}

// MARK: - Question Spacing Model (Spaced Repetition)

struct QuestionSpacingData {
    let questionId: String
    let lastAnsweredDate: Date?
    let lastResult: Bool? // nil = never answered, true = correct, false = incorrect
    let answerCount: Int
    let correctCount: Int
    
    var daysSinceLastAnswer: Int? {
        guard let date = lastAnsweredDate else { return nil }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
    
    var shouldRepeatSoon: Bool {
        guard let days = daysSinceLastAnswer else { return true } // Never answered
        guard let result = lastResult else { return true }
        return !result || days < 7 // Wrong answer or not seen in 7+ days
    }
    
    var spacingPriority: Double {
        // Priority scoring: 0.0 (low) to 1.0 (high)
        // Wrong answers (0-3 days): 0.8-1.0
        // New questions: 0.6
        // Review (7+ days): 0.4
        
        guard let result = lastResult, let days = daysSinceLastAnswer else {
            return 0.6 // New question
        }
        
        if !result { // Wrong answer
            return min(1.0, 0.8 + Double(3 - days) * 0.05)
        }
        
        if days >= 7 { // Review window
            return 0.4
        }
        
        return 0.3 // Recently correct
    }
}

// MARK: - Trial State
