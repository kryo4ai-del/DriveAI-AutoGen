import Foundation

/// Errors thrown by ProfilePersistenceService.
enum ProfilePersistenceError: LocalizedError {
    case fileNotFound
    case decodingFailed(Error)
    case encodingFailed(Error)
    case writePermissionDenied
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Profildaten nicht gefunden"
        case .decodingFailed:
            return "Profildaten sind beschädigt"
        case .encodingFailed:
            return "Fehler beim Speichern der Profildaten"
        case .writePermissionDenied:
            return "Keine Berechtigung zum Speichern"
        case .unknownError(let err):
            return "Unerwarteter Fehler: \(err.localizedDescription)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .fileNotFound:
            return "Die Profildatei existiert nicht in der App-Sandbox."
        case .decodingFailed(let err):
            return "JSON-Dekodierung fehlgeschlagen: \(err.localizedDescription)"
        case .encodingFailed(let err):
            return "JSON-Kodierung fehlgeschlagen: \(err.localizedDescription)"
        case .writePermissionDenied:
            return "Die App hat keine Schreibberechtigung für Dokumente."
        case .unknownError:
            return nil
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Versuchen Sie, die App neu zu starten, um ein neues Profil zu erstellen."
        case .decodingFailed:
            return "Kontaktieren Sie den Support oder erstellen Sie ein neues Profil."
        case .encodingFailed, .writePermissionDenied:
            return "Prüfen Sie die Speicherplatzkapazität oder starten Sie die App neu."
        case .unknownError:
            return "Versuchen Sie, die App neu zu starten."
        }
    }
}