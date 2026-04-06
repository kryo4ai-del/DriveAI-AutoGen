// MARK: - File: Services/NotificationError.swift
import Foundation

enum NotificationError: LocalizedError, Equatable {
    case permissionDenied
    case permissionNotDetermined
    case registrationFailedAfterRetries
    case invalidPayload(String)
    case fcmUnavailable
    case consentNotGiven(NotificationType)
    case networkError(String)
    case decodingError(String)
    case persistenceError(String)
    case deepLinkProcessingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Benachrichtigungen wurden in den Einstellungen deaktiviert"
        case .permissionNotDetermined:
            return "Benachrichtigungsberechtigung erforderlich"
        case .registrationFailedAfterRetries:
            return "Benachrichtigungen konnten nicht eingerichtet werden"
        case .invalidPayload(let details):
            return "Benachrichtigung ungültig: \(details)"
        case .fcmUnavailable:
            return "Benachrichtigungsdienst nicht verfügbar"
        case .consentNotGiven(let type):
            return "Zustimmung erforderlich für \(type.displayTitle)"
        case .networkError(let message):
            return "Netzwerkfehler: \(message)"
        case .decodingError(let message):
            return "Datenverarbeitungsfehler: \(message)"
        case .persistenceError(let message):
            return "Speicherfehler: \(message)"
        case .deepLinkProcessingFailed(let path):
            return "Link konnte nicht verarbeitet werden: \(path)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Öffne Einstellungen > Benachrichtigungen und aktiviere diese Funktion"
        case .registrationFailedAfterRetries:
            return "Versuche, die App neu zu starten"
        case .networkError:
            return "Überprüfe deine Internetverbindung"
        default:
            return nil
        }
    }
}
