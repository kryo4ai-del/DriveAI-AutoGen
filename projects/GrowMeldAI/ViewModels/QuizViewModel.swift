@Observable
class QuizViewModel {
    @ObservationIgnored private let quizService: QuizService
    
    // Quiz state machine (atomic updates)
    enum QuizState: Equatable {
        case loading
        case questionReady(Question, Int, Int) // question, current, total
        case answerSelected(Int) // selected option index
        case showingFeedback(Bool) // is correct
        case finished(QuizResult)
        case error(AppError)
    }
    
    @MainActor var state: QuizState = .loading
    
    @MainActor
    func selectAnswer(_ optionIndex: Int) {
        guard case .questionReady(let question, _, _) = state else {
            return // Prevent race condition: ignore selection if not in ready state
        }
        
        let isCorrect = optionIndex == question.correctOptionIndex
        state = .answerSelected(optionIndex)
        
        // Brief delay for visual feedback, then show explanation
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
            await MainActor.run {
                state = .showingFeedback(isCorrect)
            }
        }
    }
    
    @MainActor
    func nextQuestion() {
        guard case .showingFeedback(_) = state else { return }
        // State only advances from showingFeedback state
        Task {
            await loadNextQuestion()
        }
    }
}