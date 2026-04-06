@MainActor
class QuizSessionViewModel: BaseViewModel {
    @Published var currentQuestion: Question?
    @Published var userAnswers: [QuestionID: AnswerID] = [:]
    @Published var elapsedTime: Int = 0
    @Published var sessionState: SessionState = .ready
    
    enum SessionState {
        case ready, inProgress, paused, completed
    }
}