// MARK: - ViewModels/QuestionScreenViewModel.swift

import SwiftUI
import Combine

@MainActor
final class QuestionScreenViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var currentQuestion: Question?
    @Published var selectedAnswer: String?
    @Published var feedbackState: FeedbackState = .idle
    @Published var isLoading = true
    
    private let analyticsService: AnalyticsServiceProtocol
    private let questionService: QuestionService
    private let sessionManager: SessionManager
    
    private var answerStartTime: Date = Date()
    private var questionStartTime: Date = Date()
    
    // MARK: - Init
    
    init(
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
        questionService: QuestionService,
        sessionManager: SessionManager
    ) {
        self.analyticsService = analyticsService
        self.questionService = questionService
        self.sessionManager = sessionManager
        
        Task {
            await loadNextQuestion()
            await sessionManager.beginSession()
        }
    }
    
    // MARK: - Public Methods
    
    func submitAnswer(_ answer: String) {
        selectedAnswer = answer
        answerStartTime = Date()
        
        let isCorrect = questionService.validate(answer, for: currentQuestion!)
        let timeSeconds = Int(answerStartTime.timeIntervalSince(questionStartTime))
        
        // Track event asynchronously, non-blocking
        Task {
            await analyticsService.track(
                .questionAnswered(
                    categoryId: currentQuestion!.categoryId,
                    isCorrect: isCorrect,
                    timeSeconds: timeSeconds
                )
            )
        }
        
        feedbackState = isCorrect ? .correct : .incorrect
        
        // Delay next question for visual feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.loadNextQuestion()
        }
    }
    
    func skipQuestion() {
        guard let question = currentQuestion else { return }
        
        Task {
            await analyticsService.track(
                .questionSkipped(categoryId: question.categoryId)
            )
        }
        
        loadNextQuestion()
    }
    
    func endSession() {
        Task {
            await sessionManager.endSession()
        }
    }
    
    // MARK: - Private
    
    private func loadNextQuestion() {
        questionStartTime = Date()
        selectedAnswer = nil
        feedbackState = .idle
        
        Task {
            currentQuestion = try? await questionService.getNextQuestion()
            isLoading = false
        }
    }
}
