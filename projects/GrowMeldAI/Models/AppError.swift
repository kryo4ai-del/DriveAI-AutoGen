import Foundation

// NOTE: If another file in this project already declares AppError,
// that declaration should be removed or this file should be deleted.
// This file is the canonical source for AppError.

enum AppError: LocalizedError {
    case resourceNotFound
    case decodingFailed(String)
    case loadingFailed(String)
    case savingFailed(String)
    case validationFailed(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .resourceNotFound:
            return NSLocalizedString("Ressource nicht gefunden", comment: "")
        case .decodingFailed(let message):
            return NSLocalizedString("Fehler beim Laden: \(message)", comment: "")
        case .loadingFailed(let message):
            return NSLocalizedString("Fehler beim Laden: \(message)", comment: "")
        case .savingFailed(let message):
            return NSLocalizedString("Fehler beim Speichern: \(message)", comment: "")
        case .validationFailed(let message):
            return NSLocalizedString("Validierungsfehler: \(message)", comment: "")
        case .unknown(let message):
            return message
        }
    }
}