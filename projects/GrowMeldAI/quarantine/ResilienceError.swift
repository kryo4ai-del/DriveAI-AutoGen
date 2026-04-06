enum ResilienceError: LocalizedError {
    case networkUnavailable
    case operationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Netzwerk nicht verfügbar. Offline-Modus aktiv."
        case .operationFailed(let msg):
            return msg  // ❌ May contain technical details, not user-friendly
        }
    }
}

// Usage in ResilienceService:
logger.log(.error, "Failed: \(error)")  // ❌ Raw technical message