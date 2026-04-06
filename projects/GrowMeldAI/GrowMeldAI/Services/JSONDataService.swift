class JSONDataService: LocalDataService {
    enum DataLoadError: LocalizedError {
        case questionsNotFound
        case categoriesNotFound
        case decodingFailed(String)
        case invalidProgress(String)
        
        var errorDescription: String? {
            switch self {
            case .questionsNotFound:
                return "Fragen konnten nicht geladen werden. Bitte versuchen Sie, die App neu zu starten."
            case .categoriesNotFound:
                return "Kategorien konnten nicht geladen werden. Bitte versuchen Sie, die App neu zu starten."
            case .decodingFailed(let reason):
                return "Fehler beim Laden der Daten: \(reason)"
            case .invalidProgress(let reason):
                return "Ungültige Fortschrittsdaten: \(reason)"
            }
        }
    }
    
    // Announce errors to VoiceOver users
    private func announceError(_ error: DataLoadError) {
        let message = error.errorDescription ?? "Ein Fehler ist aufgetreten"
        UIAccessibility.post(
            notification: .announcement,
            argument: message
        )
    }
}