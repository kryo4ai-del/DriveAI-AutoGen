// ViewModels/ExamSimulationViewModel.swift
enum ExamState: Equatable {
    case initial
    case loadingQuestions
    case inProgress(currentQuestionIndex: Int)
    case paused
    case submitted
    case failed(score: Int)
    case passed(score: Int)
}

class ExamSimulationViewModel: ObservableObject {
    let dataService: Any
    let timerService: Any

    @Published var state: ExamState = .initial
    @Published var remainingSeconds: Int = 2700 // 45 min
    
    private var timer: Timer?
    
    func startExam() async {
        state = .loadingQuestions
        do {
            let questions = try await container.questionProvider.fetchExamSet()
            state = .inProgress(currentQuestionIndex: 0)
            startTimer()
        } catch {
            state = .failed(score: 0) // or handle gracefully
        }
    }
    
    func submitAnswer(_ answer: Int) {
        if case .inProgress(let index) = state {
            // Validate & record
            moveToNext(index)
        }
    }
}