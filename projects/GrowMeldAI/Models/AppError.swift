import Foundation

enum AppError: LocalizedError {
    case fileNotFound
    case jsonDecodingFailed(String)
    case persistenceFailed(String)
    case networkUnavailable
    case dataValidationFailed(String)
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return NSLocalizedString("Ressource nicht gefunden", comment: "")
        case .jsonDecodingFailed(let message):
            return NSLocalizedString("Fehler beim Laden: \(message)", comment: "")
        case .persistenceFailed(let message):
            return NSLocalizedString("Fehler beim Speichern: \(message)", comment: "")
        case .networkUnavailable:
            return NSLocalizedString("Netzwerk nicht verfügbar", comment: "")
        case .dataValidationFailed(let message):
            return NSLocalizedString("Validierungsfehler: \(message)", comment: "")
        case .unknownError(let message):
            return message
        }
    }
}