import Combine
import Foundation

// MARK: - State Definition
enum QuestionScreenState: Equatable {
    case idle
    case loading
    case loaded(
        question: Question,
        selectedAnswerIndex: Int?,
        submitted: Bool,
        feedback: AnswerFeedback?
    )
    case error(AppError)
    
    var question: Question? {
        if case .loaded(let q, _, _, _) = self { return q }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

// MARK: - Answer Feedback (Separate Model)

// MARK: - Actions
enum QuestionScreenAction {
    case viewDidLoad(categoryId: String, questionIndex: Int)
    case selectAnswer(index: Int)
    case submitAnswer
    case nextQuestion
    case previousQuestion
    case reset
}

// MARK: - ViewModel Implementation
@MainActor
class QuestionScreenViewModel: ObservableObject {
    @Published var state: QuestionScreenState = .idle
    
    func send(_ action: QuestionScreenAction) {
        switch action {
        case .viewDidLoad(let categoryId, let questionIndex):
            break
        case .selectAnswer(let index):
            break
        case .submitAnswer:
            break
        case .nextQuestion:
            break
        case .previousQuestion:
            break
        case .reset:
            state = .idle
        }
    }
}