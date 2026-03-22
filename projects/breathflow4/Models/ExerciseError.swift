import Foundation

enum ExerciseError: LocalizedError, Equatable {
    case dataUnavailable
    case decodingFailed(reason: String)
    case networkTimeout
    case invalidBreathPattern(reason: String)
    case invalidEmotionalOutcome
    
    var errorDescription: String? {
        switch self {
        case .dataUnavailable:
            return "No exercises available"
        case .decodingFailed(let reason):
            return "Failed to load exercises: \(reason)"
        case .networkTimeout:
            return "Connection timed out"
        case .invalidBreathPattern(let reason):
            return "Invalid breath pattern: \(reason)"
        case .invalidEmotionalOutcome:
            return "Invalid emotional outcome data"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataUnavailable:
            return "Try again in a moment."
        case .decodingFailed:
            return "Reinstalling the app may help."
        case .networkTimeout:
            return "Check your internet connection."
        case .invalidBreathPattern, .invalidEmotionalOutcome:
            return "Contact support if this persists."
        }
    }
}