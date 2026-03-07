// Models/Result.swift
import Foundation

/// Represents the result of a driving test.
struct Result {
    /// The score achieved by the user.
    let score: Int
    /// The total number of questions in the test.
    let totalQuestions: Int
    /// Indicates whether the user has passed the test.
    let isPassed: Bool
    /// Provides detailed feedback for the user based on the test outcome.
    var detailedFeedback: String {
        if isPassed {
            return LocalizedString("result.pass")
        } else {
            return LocalizedString("result.fail")
        }
    }
}