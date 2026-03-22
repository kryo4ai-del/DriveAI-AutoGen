// Models/ExerciseSelectionError.swift
import Foundation

enum ExerciseSelectionError: LocalizedError, Sendable {
    case exerciseNotFound(id: UUID)
    case performanceDataMissing(id: UUID)
    case networkFailure(String)
    case cachingFailure(String)
    case invalidScore(Double)
    case invalidCompletionCount(Int)
    case concurrencyError(String)
    case decodingFailure(String)
    case fetchFailed(String)
    case invalidSelection
    case navigationFailed

    var errorDescription: String? {
        switch self {
        case .exerciseNotFound(let id):
            return "Exercise not found: \(id)"
        case .performanceDataMissing(let id):
            return "Performance data missing for: \(id)"
        case .networkFailure(let message):
            return "Network failure: \(message)"
        case .cachingFailure(let message):
            return "Caching failure: \(message)"
        case .invalidScore(let score):
            return "Invalid score: \(score)"
        case .invalidCompletionCount(let count):
            return "Invalid completion count: \(count)"
        case .concurrencyError(let message):
            return "Concurrency error: \(message)"
        case .decodingFailure(let message):
            return "Decoding failure: \(message)"
        case .fetchFailed(let reason):
            return "Could not load exercises: \(reason)"
        case .invalidSelection:
            return "Please select a valid exercise"
        case .navigationFailed:
            return "Could not navigate to exercise"
        }
    }
}
