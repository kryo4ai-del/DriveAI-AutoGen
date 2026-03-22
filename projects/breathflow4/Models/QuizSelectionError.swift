import Foundation
// ✅ RECOMMENDED - Define clear error types
enum QuizSelectionError: LocalizedError {
    case quizNotFound(UUID)
    case filteringFailed(String)
    case persistenceFailed(Error)
    
    var errorDescription: String? { ... }
    var recoverySuggestion: String? { ... }
}