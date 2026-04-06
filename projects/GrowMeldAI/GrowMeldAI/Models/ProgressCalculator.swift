// Models/ProgressCalculator.swift
struct ProgressCalculator {
    static func percentage(current: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(current + 1) / Double(total) * 100
    }
    
    static func scorePercentage(correct: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
    
    static func categoryProgress(_ progress: CategoryProgress) -> Double {
        ProgressCalculator.scorePercentage(
            correct: progress.correctAnswers,
            total: progress.questionsAnswered
        )
    }
}

// Usage