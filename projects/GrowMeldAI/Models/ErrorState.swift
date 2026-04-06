// MARK: - ErrorState.swift
import Foundation

enum ErrorState: Equatable {
    case sync(SyncError)
    case dataCorruption(DataError)
    case validation(String)
    case unknown(String)

    // MARK: - User-Facing Messages (German)
    var userMessage: String {
        switch self {
        case .sync(let error):
            return error.localizedUserMessage
        case .dataCorruption:
            return "Daten beschädigt. Bitte neu synchronisieren."
        case .validation(let message):
            return message
        case .unknown(let message):
            return "Fehler: \(message)"
        }
    }

    var isRecoverable: Bool {
        switch self {
        case .sync(let error):
            return error.isRecoverable
        case .dataCorruption:
            return true
        case .validation:
            return true
        case .unknown:
            return false
        }
    }

    var actionButtonTitle: String? {
        isRecoverable ? "Erneut versuchen" : nil
    }
}

extension SyncError {
    var localizedUserMessage: String {
        switch self {
        case .networkUnavailable:
            return "Keine Internetverbindung. Offline-Modus aktiv."
        case .apiError(let statusCode, _):
            return "Server-Fehler (\(statusCode)). Später erneut versuchen."
        case .invalidResponse:
            return "Ungültige Antwort vom Server."
        case .decodingFailed:
            return "Daten konnten nicht gelesen werden."
        case .timeout:
            return "Verbindungs-Timeout. Bitte versuchen Sie später erneut."
        case .unknown(let error):
            return "Fehler: \(error.localizedDescription)"
        }
    }

    var isRecoverable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .apiError:
            return true
        case .invalidResponse, .decodingFailed, .unknown:
            return false
        }
    }
}