import Foundation

/// Errors thrown by reminders service layer.
/// All cases include German localization for user display.
enum RemindersError: LocalizedError, Equatable {
    case storageFailure(String)
    case permissionDenied
    case schedulingFailed(String)
    case invalidTime
    case loadingInProgress
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .storageFailure(let msg):
            return "Erinnerungen konnten nicht gespeichert werden: \(msg)"
        case .permissionDenied:
            return "Benachrichtigungserlaubnis erforderlich. Bitte aktiviere Benachrichtigungen in den Einstellungen."
        case .schedulingFailed(let msg):
            return "Planung fehlgeschlagen: \(msg)"
        case .invalidTime:
            return "Ungültige Zeit ausgewählt."
        case .loadingInProgress:
            return "Erinnerungen werden noch geladen. Bitte warte einen Moment."
        case .unknownError:
            return "Ein unbekannter Fehler ist aufgetreten."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Öffne Einstellungen > DriveAI > Benachrichtigungen und aktiviere 'Benachrichtigungen zulassen'."
        case .storageFailure, .schedulingFailed:
            return "Versuche es später erneut."
        default:
            return nil
        }
    }
}