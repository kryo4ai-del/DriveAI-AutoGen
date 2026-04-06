import Foundation

enum SyncError: LocalizedError {
    case networkTimeout
    case authExpired
    case firestoreQuotaExceeded
    case invalidData
    case offline

    var errorDescription: String? {
        switch self {
        case .networkTimeout:
            return "Synchronisierung fehlgeschlagen. Bitte versuchen Sie es später."
        case .authExpired:
            return "Session abgelaufen. Bitte melden Sie sich erneut an."
        case .firestoreQuotaExceeded:
            return "Zu viele Anfragen. Bitte warten Sie einen Moment."
        case .invalidData:
            return "Ungültige Daten. Bitte wenden Sie sich an den Support."
        case .offline:
            return "Offline-Modus. Änderungen werden beim Reconnect synchronisiert."
        }
    }
}

@MainActor
class SyncManager {
    func syncProgress() async throws {
        // no-op
    }
}