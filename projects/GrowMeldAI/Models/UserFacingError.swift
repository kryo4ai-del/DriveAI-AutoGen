enum UserFacingError: Error, LocalizedError {
    case questionNotFound
    case profileCorrupted
    case databaseUnavailable
    
    var errorDescription: String? {
        switch self {
        case .questionNotFound:
            return "Frage konnte nicht geladen werden"
        case .profileCorrupted:
            return "Benutzerprofil beschädigt. Bitte App neu starten."
        case .databaseUnavailable:
            return "Datenbank nicht verfügbar"
        }
    }
}

// In ViewModel:
func loadQuestion(id: String) async {
    isLoading = true
    errorMessage = nil
    
    do {
        guard let question = try await questionRepository.fetchQuestion(id: id) else {
            throw UserFacingError.questionNotFound
        }
        self.question = question
    } catch {
        let userMessage = (error as? LocalizedError)?.errorDescription ?? "Ein unbekannter Fehler ist aufgetreten"
        self.errorMessage = userMessage
    }
    
    isLoading = false
}