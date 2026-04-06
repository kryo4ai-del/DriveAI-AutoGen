// FeedbackError.swift – REFACTORED
enum FeedbackError: LocalizedError, Sendable {
    case validationFailed(String)
    case persistenceError(String)
    case storageExhausted
    case corruptedData(String)
    
    var errorDescription: String? {
        switch self {
        case .validationFailed(let reason):
            return reason
        case .persistenceError(let msg):
            return "Feedback konnte nicht gespeichert werden: \(msg)"
        case .storageExhausted:
            return "Speicherplatz voll. Alte Feedback-Einträge werden gelöscht."
        case .corruptedData(let detail):
            return "Feedback-Daten beschädigt: \(detail)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .validationFailed:
            return "Bitte überprüfen Sie Ihre Eingabe und versuchen Sie es erneut."
        case .persistenceError:
            return "Versuchen Sie es später noch einmal."
        case .storageExhausted:
            return "Die App gibt Speicherplatz frei. Bitte warten Sie einen Moment."
        case .corruptedData:
            return "Kontaktieren Sie support@driveai.de"
        }
    }
}

// Validation – REFACTORED
extension UserFeedback {
    enum ValidationError: LocalizedError {
        case empty
        case tooShort(minLength: Int)
        case tooLong(maxLength: Int)
        
        var errorDescription: String? {
            switch self {
            case .empty:
                return "Feedback darf nicht leer sein"
            case .tooShort(let min):
                return "Feedback muss mindestens \(min) Zeichen lang sein"
            case .tooLong(let max):
                return "Feedback darf höchstens \(max) Zeichen lang sein"
            }
        }
    }
    
    static func validate(message: String) throws {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            throw ValidationError.empty
        }
        
        guard trimmed.count >= 5 else {
            throw ValidationError.tooShort(minLength: 5)
        }
        
        guard trimmed.count <= 500 else {
            throw ValidationError.tooLong(maxLength: 500)
        }
    }
}