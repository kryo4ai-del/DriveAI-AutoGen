import Foundation

enum TrainingModeState: Equatable {
    case idle
    case categorySelection
    case loadingQuestions(categoryId: String)
    case answering(questionIndex: Int, total: Int)
    case showingFeedback(isCorrect: Bool, selectedAnswerId: String)
    case sessionPaused(sessionId: UUID)
    case sessionComplete(result: TrainingResult)
    case error(TrainingError)
    
    var isAnswering: Bool {
        if case .answering = self { return true }
        return false
    }
    
    var isShowingFeedback: Bool {
        if case .showingFeedback = self { return true }
        return false
    }
}

enum TrainingError: LocalizedError, Equatable {
    case categoriesNotFound
    case questionsLoadFailed(categoryId: String)
    case invalidSessionData
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .categoriesNotFound:
            return NSLocalizedString("training.error.no_categories", comment: "")
        case .questionsLoadFailed(let categoryId):
            return String(format: NSLocalizedString("training.error.load_failed", comment: ""), categoryId)
        case .invalidSessionData:
            return NSLocalizedString("training.error.invalid_session", comment: "")
        case .databaseError(let message):
            return message
        }
    }
}
