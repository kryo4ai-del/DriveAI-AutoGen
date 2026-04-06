import Foundation

enum ConsentError: LocalizedError {
    case systemAuthorizationDenied
    case notificationSchedulingFailed(Error)
    case storageFailure

    var errorDescription: String? {
        switch self {
        case .systemAuthorizationDenied:
            return "Benachrichtigungen wurden auf Systemebene abgelehnt. Bitte aktiviere sie in den Einstellungen."
        case .notificationSchedulingFailed(let error):
            return "Benachrichtigungen konnten nicht geplant werden: \(error.localizedDescription)"
        case .storageFailure:
            return "Einstellungen konnten nicht gespeichert werden. Bitte versuche es erneut."
        }
    }
}