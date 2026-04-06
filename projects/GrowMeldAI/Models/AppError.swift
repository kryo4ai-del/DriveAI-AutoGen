import Foundation

// AppError is defined here; extension lives in AppError+Extension.swift
enum AppError: LocalizedError {
    case fileNotFound
    case jsonDecodingFailed
    case persistenceFailed
    case networkUnavailable
    case dataValidationFailed
    case unknownError

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return NSLocalizedString("Ressource nicht gefunden", comment: "")
        case .jsonDecodingFailed:
            return NSLocalizedString("Fehler beim Laden der Daten", comment: "")
        case .persistenceFailed:
            return NSLocalizedString("Fehler beim Speichern", comment: "")
        case .networkUnavailable:
            return NSLocalizedString("Netzwerk nicht verfügbar", comment: "")
        case .dataValidationFailed:
            return NSLocalizedString("Validierungsfehler", comment: "")
        case .unknownError:
            return NSLocalizedString("Unbekannter Fehler", comment: "")
        }
    }
}