// Models/AppError.swift
import Foundation

enum AppError: LocalizedError, Identifiable {
    case loadingFailed(String)
    case decodingFailed
    case notFound
    case persistenceFailed(String)
    case unknown(String? = nil)
    
    var id: String { errorDescription ?? "unknown_error" }
    
    var errorDescription: String? {
        switch self {
        case .loadingFailed(let message):
            return "Failed to load: \(message)"
        case .decodingFailed:
            return "Unable to parse exercise data"
        case .notFound:
            return "Exercise not found"
        case .persistenceFailed(let message):
            return "Unable to save: \(message)"
        case .unknown(let message):
            return message ?? "An unexpected error occurred"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .loadingFailed:
            return "Check your internet connection and try again."
        case .decodingFailed:
            return "The exercise data may be corrupted. Please restart the app."
        case .notFound:
            return "This exercise is no longer available."
        case .persistenceFailed:
            return "There was an issue saving your progress. Try again."
        case .unknown:
            return "Please try again or contact support if the problem persists."
        }
    }
}