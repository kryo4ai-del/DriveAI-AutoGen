enum DiagnosticEngineError: LocalizedError {
    case dataServiceUnavailable(String)
    case corruptedSnapshot(String)
    case persistenceFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .dataServiceUnavailable(let msg):
            return "Learning diagnostics temporarily unavailable: \(msg)"
        case .corruptedSnapshot(let msg):
            return "Unable to load your progress: \(msg)"
        case .persistenceFailure(let msg):
            return "Failed to save progress: \(msg)"
        }
    }
}

// In ViewModel: Handle error explicitly