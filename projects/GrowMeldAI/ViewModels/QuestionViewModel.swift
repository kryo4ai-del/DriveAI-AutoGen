// Features/Questions/ViewModels/QuestionViewModel.swift
@MainActor
final class QuestionViewModel: ObservableObject {
    @Published private(set) var state: QuestionState = .idle
    @Published private(set) var progress: (current: Int, total: Int) = (0, 0)
    @Published private(set) var streak: Int = 0
    
    // Dependencies (injected, never @StateObject)
    private let questionService: QuestionService
    private let analyticsService: AnalyticsService
    private weak var coordinator: AppCoordinator?
    
    private var questions: [Question] = []
    private var currentIndex: Int = 0
    
    init(
        questionService: QuestionService,
        analyticsService: AnalyticsService,
        coordinator: AppCoordinator
    ) {
        self.questionService = questionService
        self.analyticsService = analyticsService
        self.coordinator = coordinator
    }
    
    // MARK: - State Machine
    
    func loadQuestions(category: Category? = nil) async {
        state = .loading
        do {
            questions = try await questionService.fetchQuestions(category: category)
            currentIndex = 0
            await presentNextQuestion()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func selectAnswer(_ answerID: String) {
        guard case .presenting(let question, _) = state else { return }
        state = .presenting(question: question, selectedAnswer: answerID)
    }
    
    func submitAnswer() async {
        guard case .presenting(let question, let selectedAnswer) = state,
              let answer = selectedAnswer else { return }
        
        let isCorrect = questionService.checkAnswer(answer, for: question)
        let explanation = question.explanation ?? "No explanation available"
        
        state = .submitted(
            question: question,
            selectedAnswer: answer,
            isCorrect: isCorrect,
            explanation: explanation
        )
        
        // Track analytics
        analyticsService.recordAnswer(
            questionID: question.id,
            correct: isCorrect,
            category: question.category
        )
        
        // Update streak
        if isCorrect {
            streak += 1
        } else {
            streak = 0
        }
    }
    
    func nextQuestion() async {
        currentIndex += 1
        if currentIndex < questions.count {
            await presentNextQuestion()
        } else {
            // Quiz complete
            coordinator?.navigate(to: .results)
        }
    }
    
    private func presentNextQuestion() async {
        guard currentIndex < questions.count else { return }
        let question = questions[currentIndex]
        state = .presenting(question: question)
        progress = (currentIndex + 1, questions.count)
    }
}