enum UIError: LocalizedError {
    case transient(String)      // Retry recommended
    case persistent(String)     // User action needed
    
    var isTransient: Bool {
        if case .transient = self { return true }
        return false
    }
}

// [FK-019 sanitized] catch {
// [FK-019 sanitized]     if let uiError = error as? UIError, uiError.isTransient {
// [FK-019 sanitized]         self.showRetryButton = true
// [FK-019 sanitized]         self.error = error.localizedDescription
// [FK-019 sanitized]     } else {
// [FK-019 sanitized]         self.showRetryButton = false
// [FK-019 sanitized]         self.error = "Fehler: \(error.localizedDescription)"
// [FK-019 sanitized]     }
// [FK-019 sanitized] }