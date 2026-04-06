// Domain/Coaching/CoachingError.swift

import Foundation

public enum CoachingError: LocalizedError {
    case insufficientData(message: String)
    case invalidStrategy
    case prioritizationFailed
    case repositoryUnavailable(underlying: Error)
    case encodingFailed(underlying: Error)
    
    public var errorDescription: String? {
        switch self {
        case .insufficientData(let msg):
            return "Nicht genug Daten: \(msg)"
        case .invalidStrategy:
            return "Coaching-Strategie ungültig"
        case .prioritizationFailed:
            return "Priorisierung fehlgeschlagen"
        case .repositoryUnavailable(let error):
            return "Datenspeicher nicht verfügbar: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Kodierungsfehler: \(error.localizedDescription)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .insufficientData:
            return "Versuche, ein paar mehr Fragen zu üben."
        case .invalidStrategy:
            return "Bitte melde diesen Fehler."
        case .repositoryUnavailable:
            return "Prüfe deine Internetverbindung."
        default:
            return nil
        }
    }
}
