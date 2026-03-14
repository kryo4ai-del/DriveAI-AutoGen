// Models/Progress/ValidationError.swift
import Foundation

/// Validation errors for progress models.
enum ProgressValidationError: LocalizedError {
    case negativeAttemptCount(Int)
    case negativeCorrectCount(Int)
    case correctCountExceedsAttempts(correct: Int, attempts: Int)
    case completedExceedsStarted(completed: Int, started: Int)
    
    var errorDescription: String? {
        switch self {
        case .negativeAttemptCount(let value):
            return "Attempt count cannot be negative: \(value)"
        case .negativeCorrectCount(let value):
            return "Correct count cannot be negative: \(value)"
        case .correctCountExceedsAttempts(let correct, let attempts):
            return "Correct count (\(correct)) cannot exceed attempts (\(attempts))"
        case .completedExceedsStarted(let completed, let started):
            return "Completed categories (\(completed)) cannot exceed started (\(started))"
        }
    }
}

// Models/Progress/ProgressValidator.swift
struct ProgressValidator {
    /// Validates attempt/correct count pair.
    static func validateAttempts(count: Int, correct: Int) throws {
        guard count >= 0 else { throw ProgressValidationError.negativeAttemptCount(count) }
        guard correct >= 0 else { throw ProgressValidationError.negativeCorrectCount(correct) }
        guard correct <= count else {
            throw ProgressValidationError.correctCountExceedsAttempts(correct: correct, attempts: count)
        }
    }
    
    /// Validates category counts.
    static func validateCategories(started: Int, completed: Int) throws {
        guard completed <= started else {
            throw ProgressValidationError.completedExceedsStarted(completed: completed, started: started)
        }
    }
}