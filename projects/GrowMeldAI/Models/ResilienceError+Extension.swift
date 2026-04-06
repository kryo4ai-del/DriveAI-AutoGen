// File: Domain/Models/ResilienceError.swift

extension ResilienceError {
    
    /// User-facing error message (for UI display)
    var userMessage: String {
        switch self {
        case .network(let failure):
            return failure.userMessage
        case .sync(let failure):
            return failure.userMessage
        case .offline(let failure):
            return failure.userMessage
        }
    }
    
    /// Accessibility-optimized VoiceOver announcement
    /// Structured for clarity: category, specific issue, action
    var accessibilityMessage: String {
        switch self {
        case .network(.connectionLost):
            return "Verbindungsfehler. Du bist vom Internet getrennt. Bitte überprüfe deine Internetverbindung und versuche es erneut."
        case .network(.timeout(let seconds)):
            return "Verbindungsfehler. Die Anfrage hat zu lange gedauert, etwa \(seconds) Sekunden. Bitte versuche es erneut."
        case .network(.serverError(let code)):
            return "Fehler auf dem Server mit Code \(code). Bitte versuche es in einigen Minuten erneut."
        case .sync(.conflictDetected(let resourceId)):
            return "Synchronisierungskonflikt für Frage \(resourceId). Deine lokale Antwort unterscheidet sich von der auf dem Server. Du kannst deine lokale Version behalten oder die Server-Version übernehmen."
        case .offline(.cachedDataStale(let date)):
            let dateStr = Self.dateFormatter.string(from: date)
            return "Du arbeitest mit zwischengespeicherten Daten von \(dateStr). Um die neuesten Fragen zu sehen, stelle bitte eine Internetverbindung her."
        case .offline(.resourceNotFound(let resourceId)):
            return "Frage \(resourceId) ist nicht im lokalen Speicher verfügbar. Stelle eine Internetverbindung her, um diese Frage zu laden."
        default:
            return userMessage
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

// Sub-error localization
extension ResilienceError.NetworkFailure {
    var userMessage: String {
        switch self {
        case .connectionLost:
            return "Verbindung verloren. Bitte überprüfe deine Internetverbindung."
        case .timeout(let seconds):
            return "Anfrage zu langsam (>\(seconds)s). Bitte versuche es erneut."
        case .dnsFailure:
            return "Internet-Verbindung konnte nicht hergestellt werden. Bitte überprüfe deine Einstellungen."
        case .serverError(let code):
            return "Server-Fehler (\(code)). Bitte versuche es später erneut."
        case .invalidResponse:
            return "Ungültige Antwort vom Server. Bitte aktualisiere die App."
        case .unknown(let code):
            return "Unbekannter Fehler: \(code)"
        }
    }
}