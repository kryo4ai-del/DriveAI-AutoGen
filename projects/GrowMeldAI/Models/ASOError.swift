enum ASOError: LocalizedError {
    case networkUnavailable
    case apiRateLimited(retryAfter: TimeInterval)
    case invalidResponse
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Netzwerk nicht verfügbar. Zeige Cache an."
        case .apiRateLimited(let after):
            return "Rate limit erreicht. Versuche in \(Int(after))s erneut."
        default:
            return "Fehler beim Laden der Daten."
        }
    }
}