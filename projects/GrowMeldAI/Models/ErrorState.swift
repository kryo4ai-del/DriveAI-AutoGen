import Foundation

enum GrowMeldSyncError: Error, Equatable {
    case networkUnavailable
    case apiError(Int, String)
    case invalidResponse
    case decodingFailed
    case timeout
    case unknown(String)

    static func == (lhs: GrowMeldSyncError, rhs: GrowMeldSyncError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnavailable, .networkUnavailable): return true
        case (.apiError(let a, let b), .apiError(let c, let d)): return a == c && b == d
        case (.invalidResponse, .invalidResponse): return true
        case (.decodingFailed, .decodingFailed): return true
        case (.timeout, .timeout): return true
        case (.unknown(let a), .unknown(let b)): return a == b
        default: return false
        }
    }

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
        case .unknown(let message):
            return "Fehler: \(message)"
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

typealias SyncError = GrowMeldSyncError

enum AppDataError: Error, Equatable {
    case corrupted(String)
    case notFound(String)
    case saveFailed(String)
}

enum ErrorState: Equatable {
    case sync(GrowMeldSyncError)
    case dataCorruption(AppDataError)
    case validation(String)
    case unknown(String)

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

    static func == (lhs: ErrorState, rhs: ErrorState) -> Bool {
        switch (lhs, rhs) {
        case (.sync(let a), .sync(let b)): return a == b
        case (.dataCorruption(let a), .dataCorruption(let b)): return a == b
        case (.validation(let a), .validation(let b)): return a == b
        case (.unknown(let a), .unknown(let b)): return a == b
        default: return false
        }
    }
}