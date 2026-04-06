import Foundation
enum MaintenanceServiceError: LocalizedError {
    case statsServiceUnavailable(underlyingError: Error? = nil)
    case categoryServiceUnavailable(underlyingError: Error? = nil)
    case persistenceError(String, underlyingError: Error? = nil)
    case checkNotFound(UUID)
    case invalidSchedule(String)
    case concurrencyViolation(String)
    
    var errorDescription: String? {
        switch self {
        case .statsServiceUnavailable:
            return "Statistik-Service nicht verfügbar"
        case .categoryServiceUnavailable:
            return "Kategorie-Service nicht verfügbar"
        case .persistenceError(let msg, _):
            return "Speicherfehler: \(msg)"
        case .checkNotFound(let id):
            return "Check mit ID \(id) nicht gefunden"
        case .invalidSchedule(let msg):
            return "Ungültiges Schedule: \(msg)"
        case .concurrencyViolation(let msg):
            return "Gleichzeitigkeitsfehler: \(msg)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .statsServiceUnavailable:
            return "Bitte versuchen Sie es später erneut oder starten Sie die App neu."
        case .persistenceError:
            return "Überprüfen Sie den verfügbaren Speicherplatz und versuchen Sie es später erneut."
        case .checkNotFound:
            return "Dieser Check wurde möglicherweise gelöscht."
        default:
            return nil
        }
    }
}