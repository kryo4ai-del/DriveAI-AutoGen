// ✅ FIXED – explicit error contract
enum DataServiceError: LocalizedError {
    case databaseNotInitialized
    case questionNotFound(id: String)
    case categoryNotFound(id: String)
    case invalidQuestionData(reason: String)
    case corruptedDatabase(reason: String)
    case seedDataMissing
    
    var errorDescription: String? {
        switch self {
        case .questionNotFound(let id):
            return "Frage '\(id)' nicht gefunden"
        case .corruptedDatabase(let reason):
            return "Datenbankfehler: \(reason)"
        // ...
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .corruptedDatabase: return true  // Can recover via reseed
        default: return false
        }
    }
}

// Implementation

// ViewModel now has reliable error handling:
do {
    questions = try await dataService.fetchQuestions(for: categoryId)
} catch let err as DataServiceError {
    switch err {
    case .categoryNotFound(let id):
        error = AppError.notFound("Kategorie '\(id)' nicht verfügbar")
    case .corruptedDatabase(let reason):
        error = AppError.databaseError(reason)
        // Offer reseed recovery action
    default:
        error = AppError.unknown(err.errorDescription ?? "Unbekannter Fehler")
    }
} catch {
    error = AppError.unknown(error.localizedDescription)
}