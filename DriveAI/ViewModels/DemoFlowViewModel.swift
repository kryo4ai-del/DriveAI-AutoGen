import Combine

class DemoFlowViewModel: ObservableObject {
    @Published var questions: [QuestionModel] = []
    @Published var currentIndex: Int = 0
    @Published var results: QuizResult?
    @Published var feedbackMessage: String? // Feedback for correctness
    @Published var errorMessage: String? // Error handling
    @Published var isLoading: Bool = true // Loading state
    private var cancellables = Set<AnyCancellable>()
    private let dataService: LocalDataService
    
    init(dataService: LocalDataService) {
        self.dataService = dataService
        loadQuestions()
    }

    func loadQuestions() {
        dataService.fetchQuestions()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in self.isLoading = false })
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription // Set error message
                }
            }, receiveValue: { [weak self] questions in
                self?.questions = questions
            })
            .store(in: &cancellables)
    }

    func submitAnswer(selectedAnswer: UUID) {
        let isCorrect = selectedAnswer == questions[currentIndex].correctAnswer
        feedbackMessage = isCorrect ? "Correct!" : "Incorrect!"
        
        if isCorrect {
            // Increment correct answer count logic can be implemented here
        }
        
        if currentIndex < questions.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.currentIndex += 1
                self.feedbackMessage = nil // Reset feedback message
            }
        } else {
            calculateResults()
        }
    }

    private func calculateResults() {
        // Logic to prepare the results for display
        results = QuizResult(correctAnswers: 0, totalQuestions: questions.count) // Placeholder logic
    }
}