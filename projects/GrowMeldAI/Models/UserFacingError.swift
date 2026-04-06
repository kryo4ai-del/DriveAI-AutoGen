import Foundation

enum UserFacingError: Error, LocalizedError {
    case questionNotFound
    case profileCorrupted
    case databaseUnavailable

    var errorDescription: String? {
        switch self {
        case .questionNotFound:
            return "Frage konnte nicht geladen werden"
        case .profileCorrupted:
            return "Benutzerprofil beschädigt. Bitte App neu starten."
        case .databaseUnavailable:
            return "Datenbank nicht verfügbar"
        }
    }
}