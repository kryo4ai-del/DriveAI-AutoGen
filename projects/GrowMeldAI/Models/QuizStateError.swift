enum QuizStateError: LocalizedError {
    case invalidStateTransition(from: String, action: String)
    case noMoreQuestions
    
    var errorDescription: String? {
        switch self {
        case .invalidStateTransition(let from, let action):
            return "Ungültige Aktion '\(action)' im Status '\(from)'"
        case .noMoreQuestions:
            return "Keine weiteren Fragen verfügbar"
        }
    }
}

@MainActor