// Services/AIExplanationService.swift
import Foundation

enum ExplanationError: LocalizedError {
    case networkUnavailable
    case apiTimeout
    case invalidResponse
    case cacheMiss
    case allTiersFailed

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return "Netzwerk nicht verfügbar"
        case .apiTimeout: return "Zeitüberschreitung bei KI-Anfrage"
        case .invalidResponse: return "Ungültige KI-Antwort"
        case .cacheMiss: return "Erklärung nicht im Cache"
        case .allTiersFailed: return "Alle Erklärungsebenen fehlgeschlagen"
        }
    }
}
