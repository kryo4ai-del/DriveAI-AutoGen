enum UIError: LocalizedError {
    case transient(String)      // Retry recommended
    case persistent(String)     // User action needed
    
    var isTransient: Bool {
        if case .transient = self { return true }
        return false
    }
}

catch {
    if let uiError = error as? UIError, uiError.isTransient {
        self.showRetryButton = true
        self.error = error.localizedDescription
    } else {
        self.showRetryButton = false
        self.error = "Fehler: \(error.localizedDescription)"
    }
}