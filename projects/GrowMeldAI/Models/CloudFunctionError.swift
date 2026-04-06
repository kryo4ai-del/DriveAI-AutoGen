import Foundation

enum CloudFunctionError: LocalizedError, Equatable {
    case networkUnavailable
    case functionTimeout(retryCount: Int)
    case invalidResponse(statusCode: Int)
    case authenticationFailed
    case quotaExceeded
    case decodingError(String)
    case unknownFunction
    case badRequest(String)
    case serverError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Netzwerkverbindung erforderlich. Bitte überprüfen Sie Ihre Internetverbindung."
        case .functionTimeout(let retry):
            return "Anfrage abgelaufen (Versuch \(retry)). Bitte versuchen Sie es später erneut."
        case .invalidResponse(let code):
            return "Ungültige Antwort vom Server (Code: \(code))."
        case .authenticationFailed:
            return "Authentifizierung fehlgeschlagen. Bitte melden Sie sich erneut an."
        case .quotaExceeded:
            return "Zu viele Anfragen. Bitte warten Sie vor dem nächsten Versuch."
        case .decodingError(let detail):
            return "Datenverarbeitungsfehler: \(detail)"
        case .unknownFunction:
            return "Funktion nicht gefunden."
        case .badRequest(let detail):
            return "Ungültige Anfrage: \(detail)"
        case .serverError(let detail):
            return "Serverfehler: \(detail)"
        case .unknown(let detail):
            return "Unbekannter Fehler: \(detail)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Ihre Änderungen werden lokal gespeichert und synchronisiert, wenn die Verbindung hergestellt ist."
        case .functionTimeout:
            return "Versuchen Sie es in einem Moment erneut."
        case .authenticationFailed:
            return "Melden Sie sich im Profilbildschirm an."
        case .quotaExceeded:
            return "Bitte warten Sie einige Minuten, bevor Sie es erneut versuchen."
        default:
            return "Bitte versuchen Sie es später erneut oder kontaktieren Sie den Support."
        }
    }
    
    // For retry logic
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .functionTimeout, .quotaExceeded:
            return true
        default:
            return false
        }
    }
}

extension CloudFunctionError {
    init(from functionsError: NSError) {
        let code = functionsError.code
        let userInfo = functionsError.userInfo
        
        switch code {
        case -1001:
            self = .functionTimeout(retryCount: 0)
        case -1009:
            self = .networkUnavailable
        case 0:
            if let details = userInfo["details"] as? String {
                self = .decodingError(details)
            } else {
                self = .unknown(functionsError.localizedDescription)
            }
        default:
            self = .unknown(functionsError.localizedDescription)
        }
    }
}