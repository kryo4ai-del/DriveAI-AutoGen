enum FallbackError: LocalizedError, Sendable {
    case resourceNotFound(String)
    case notFound(String)
    case decodingFailed(String)
    case timeout
    
    var errorDescription: String? {
        userFriendlyDescription
    }
    
    var userFriendlyDescription: String {
        switch self {
        case .resourceNotFound(let file):
            return "Die Fragendatenbank konnte nicht geladen werden. Bitte versuchen Sie es später erneut."
        case .notFound(let item):
            return "Die angeforderte Frage oder Kategorie ist nicht verfügbar."
        case .decodingFailed:
            return "Die Fragendatenbank ist beschädigt. Die App verwendet Offline-Modus."
        case .timeout:
            return "Die Anfrage hat zu lange gedauert. Verwenden Sie Offline-Modus."
        }
    }
    
    var technicalDescription: String {
        // For logging/debugging only
        switch self {
        case .resourceNotFound(let file):
            return "Resource not found: \(file)"
        case .notFound(let item):
            return "Item not found: \(item)"
        case .decodingFailed(let reason):
            return "Decoding failed: \(reason)"
        case .timeout:
            return "Timeout error"
        }
    }
}