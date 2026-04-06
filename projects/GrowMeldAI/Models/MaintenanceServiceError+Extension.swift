extension MaintenanceServiceError {
    var recoverySuggestion: String {
        switch self {
        case .statsServiceUnavailable:
            return "Bitte versuchen Sie es später erneut oder starten Sie die App neu."
        case .persistenceError(let msg):
            return "Ihre Daten konnten nicht gespeichert werden: \(msg)"
        default:
            return "Ein unerwarteter Fehler ist aufgetreten."
        }
    }
}