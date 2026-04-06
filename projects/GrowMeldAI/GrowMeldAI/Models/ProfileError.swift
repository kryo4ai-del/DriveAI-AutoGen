import Foundation

/// Manages user profile persistence and state with thread-safe access
@globalActor

// MARK: - Errors

enum ProfileError: LocalizedError {
    case profileNotFound
    case invalidExamDate
    case encodingFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "Benutzerprofil nicht gefunden"
        case .invalidExamDate:
            return "Das Prüfdatum muss in der Zukunft liegen"
        case .encodingFailed:
            return "Fehler beim Speichern des Profils"
        case .decodingFailed:
            return "Fehler beim Laden des Profils"
        }
    }
}