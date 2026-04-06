// Services/Errors/ServiceError.swift
import Foundation

enum ServiceError: LocalizedError, Equatable {
    case questionsNotFound
    case invalidJSON(String)
    case storageFailure(String)
    case databaseCorruption
    case userProgressNotFound(UUID)
    case invalidExamState
    case decodingFailure
    
    var errorDescription: String? {
        switch self {
        case .questionsNotFound:
            return NSLocalizedString("Fragen nicht gefunden", comment: "Question data missing")
        case .invalidJSON(let details):
            return NSLocalizedString("Fehler beim Laden der Daten: \(details)", comment: "JSON parse error")
        case .storageFailure(let details):
            return NSLocalizedString("Speicherfehler: \(details)", comment: "Storage write failed")
        case .databaseCorruption:
            return NSLocalizedString("Datenbank beschädigt", comment: "Data integrity issue")
        case .userProgressNotFound(let userId):
            return NSLocalizedString("Fortschritt für Benutzer \(userId) nicht gefunden", comment: "User progress missing")
        case .invalidExamState:
            return NSLocalizedString("Ungültiger Prüfungsstatus", comment: "Invalid exam state transition")
        case .decodingFailure:
            return NSLocalizedString("Fehler beim Dekodieren der Daten", comment: "Decoding failed")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .questionsNotFound:
            return NSLocalizedString("Bitte aktualisieren Sie die App", comment: "")
        case .storageFailure:
            return NSLocalizedString("Bitte stellen Sie sicher, dass genügend Speicher vorhanden ist", comment: "")
        default:
            return NSLocalizedString("Bitte versuchen Sie es später erneut", comment: "")
        }
    }
}