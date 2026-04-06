// MARK: - State Definition
enum QuestionViewState {
    case idle
    case loading
    case loaded(question: Question, progress: QuestionProgress)
    case submitting
    case feedback(isCorrect: Bool, explanation: String)
    case error(Error)
}

// MARK: - ViewModel (Testable)
@MainActor