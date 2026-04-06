// File: ViewModels/QuestionViewModel.swift
import Foundation
import Combine

enum QuizError: Error, LocalizedError {
    case questionNotFound
    case dataUnavailable
    case invalidAnswer
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .questionNotFound: return "Frage nicht gefunden"
        case .dataUnavailable: return "Daten nicht verfügbar"
        case .invalidAnswer: return "Ungültige Antwort"
        case .networkError: return "Netzwerkfehler"
        case .unknown: return "Unbekannter Fehler"
        }
    }
}
