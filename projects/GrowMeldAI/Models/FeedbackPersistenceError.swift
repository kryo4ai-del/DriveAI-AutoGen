import Foundation
enum FeedbackPersistenceError: LocalizedError {
    case fileNotFound(path: String)
    case fileCopyFailed(Error)
    case decodingFailed(String, Error)
    case encodingFailed(Error)
    case fileWriteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Feedbackdatei nicht gefunden: \(path). Datenbank wird zurückgesetzt."
        case .decodingFailed(let context, _):
            return "Fehler beim Lesen von Feedback (\(context)). Einzelne Einträge werden übersprungen."
        case .encodingFailed:
            return "Fehler beim Speichern von Feedback. Bitte versuchen Sie es später erneut."
        case .fileWriteFailed:
            return "Speicher voll oder Dateisystem schreibgeschützt."
        case .fileCopyFailed:
            return "Backup-Fehler. Daten könnten verloren gehen."
        }
    }
    
    var recoveryAction: String {
        switch self {
        case .fileNotFound:
            return "Datenbank zurücksetzen"
        case .decodingFailed:
            return "Fehlerhafte Einträge ignorieren"
        case .encodingFailed, .fileWriteFailed, .fileCopyFailed:
            return "Speicher überprüfen und erneut versuchen"
        }
    }
}