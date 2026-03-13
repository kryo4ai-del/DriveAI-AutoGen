import SwiftUI
import Combine

// MARK: - Navigation Destination

enum TrainingModeDestination: Hashable {
    case categorySelection
    case question
    case results
}

// MARK: - Error Types

enum TrainingModeError: LocalizedError {
    case noCategoriesAvailable
    case questionsLoadFailed(String)
    case sessionNotFound
    case persistenceFailed(String)
    case invalidAnswerSelection
    case questionStartTimeNotSet
    
    var errorDescription: String? {
        switch self {
        case .noCategoriesAvailable:
            return NSLocalizedString("error_no_categories", comment: "")
        case .questionsLoadFailed(let reason):
            return String(format: NSLocalizedString("error_questions_load_failed", comment: ""), reason)
        case .sessionNotFound:
            return NSLocalizedString("error_session_not_found", comment: "")
        case .persistenceFailed(let reason):
            return String(format: NSLocalizedString("error_persistence_failed", comment: ""), reason)
        case .invalidAnswerSelection:
            return NSLocalizedString("error_invalid_answer", comment: "")
        case .questionStartTimeNotSet:
            return NSLocalizedString("error_timing", comment: "")
        }
    }
}

// MARK: - View Model

@Observable
final class TrainingModeViewModel: NSObject {
    
    // MARK: - Session State
    var currentSession: TrainingSession?
    var currentQuestion: QuestionWithCategory?
    var allQuestionsForSession: [Question] = []
    
    // MARK: - UI State
    var selectedAnswer: String?
    var showExplanation: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var sessionResult: TrainingResult?
    
    // MARK: - Navigation State
    @ObservationIgnored var navigationPath = NavigationPath()
    var showExitConfirmation = false
    
    // MARK: - Recovery State
    var canRetry: Bool = false
    @ObservationIgnored private var lastFailedContext: (categoryId: String, categoryName: String)?
    
    // MARK: - Timing
    @ObservationIgnored private(set) var questionStartTime: Date?
    @ObservationIgnored private let maxQuestionTimeInterval: TimeInterval = 3600 // 1 hour max
    
    // MARK: - Dependencies
    private let dataService: LocalDataService
    private let sessionManager: TrainingSessionManager
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        dataService: LocalDataService = LocalDataService.shared,
        sessionManager: TrainingSessionManager = TrainingSessionManager.shared
    ) {
        self.dataService = dataService
        self.sessionManager = sessionManager
        super.init()
    }
    
    // MARK: - Session Lifecycle
    
    @MainActor
    func startTrainingSession(categoryId: String, categoryName: String) async {
        isLoading = true
        errorMessage = nil
        canRetry = false
        lastFailedContext = (categoryId, categoryName)
        
        do {
            let questions = try await dataService.getQuestionsByCategory(categoryId)
            guard !questions.isEmpty else {
                throw TrainingModeError.noCategoriesAvailable
            }
            
            let session = TrainingSession(
                id: UUID(),
                categoryId: categoryId,
                categoryName: categoryName,
                startedAt: Date()
            )
            
            self.currentSession = session
            self.allQuestionsForSession = questions.shuffled()
            
            // Load first question
            await loadQuestion(at: 0)
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            canRetry = true
        }
    }
    
    @MainActor
    func retryLastAction() async {
        guard let (categoryId, categoryName) = lastFailedContext else {
            errorMessage = "Retry context lost"
            return
        }
        await startTrainingSession(categoryId: categoryId, categoryName: categoryName)
    }
    
    @MainActor
    func endSession(saveResults: Bool = false) async {
        guard currentSession != nil else { return }
        
        if saveResults {
            await persistSessionResult()
        }
        
        resetSessionState()
    }
    
    @MainActor
    func resetSessionState() {
        currentSession = nil
        currentQuestion = nil
        allQuestionsForSession = []
        selectedAnswer = nil
        showExplanation = false
        sessionResult = nil
        errorMessage = nil
        questionStartTime = nil
        canRetry = false
        lastFailedContext = nil
        showExitConfirmation = false
    }
    
    // MARK: - Question Navigation
    
    @MainActor
    private func loadQuestion(at index: Int) async {
        guard index < allQuestionsForSession.count else {
            await finalizeSession()
            return
        }
        
        let question = allQuestionsForSession[index]
        currentQuestion = QuestionWithCategory(
            question: question,
            categoryName: currentSession?.categoryName ?? "",
            questionNumber: index + 1,
            totalQuestions: allQuestionsForSession.count
        )
        
        // Reset UI state for new question
        selectedAnswer = nil
        showExplanation = false
        questionStartTime = Date()
    }
    
    @MainActor
    func nextQuestion() async {
        guard let session = currentSession else { return }
        
        let nextIndex = session.currentQuestionIndex
        
        if nextIndex < allQuestionsForSession.count {
            await loadQuestion(at: nextIndex)
        } else {
            await finalizeSession()
        }
    }
    
    @MainActor
    func previousQuestion() async {
        guard let session = currentSession else { return }
        guard session.currentQuestionIndex > 0 else { return }
        
        let previousIndex = session.currentQuestionIndex - 1
        await loadQuestion(at: previousIndex)
    }
    
    @MainActor
    func skipQuestion() async {
        guard let session = currentSession,
              let question = currentQuestion else { return }
        
        let timeSpent = calculateTimeSpent()
        
        let completedQuestion = CompletedQuestion(
            questionId: question.question.id,
            selectedAnswer: "",
            isCorrect: false,
            timeSpent: timeSpent,
            explanationRead: false
        )
        
        let updatedSession = session.withCompletedQuestion(completedQuestion)
        currentSession = updatedSession
        
        await nextQuestion()
    }
    
    // MARK: - Answer Submission
    
    @MainActor
    func submitAnswer(_ selectedOption: String) async {
        guard !selectedOption.isEmpty else {
            errorMessage = TrainingModeError.invalidAnswerSelection.localizedDescription
            return
        }
        
        guard let session = currentSession,
              let question = currentQuestion else { return }
        
        // Prevent double-submission
        guard selectedAnswer == nil else { return }
        
        selectedAnswer = selectedOption
        
        let timeSpent = calculateTimeSpent()
        let isCorrect = selectedOption == question.question.correctAnswer
        
        let completedQuestion = CompletedQuestion(
            questionId: question.question.id,
            selectedAnswer: selectedOption,
            isCorrect: isCorrect,
            timeSpent: timeSpent,
            explanationRead: false
        )
        
        let updatedSession = session.withCompletedQuestion(completedQuestion)
        currentSession = updatedSession
    }
    
    @MainActor
    func toggleExplanation() {
        showExplanation.toggle()
        
        guard var session = currentSession,
              !session.completedQuestions.isEmpty else { return }
        
        let lastIndex = session.completedQuestions.count - 1
        session.completedQuestions[lastIndex] = CompletedQuestion(
            questionId: session.completedQuestions[lastIndex].questionId,
            selectedAnswer: session.completedQuestions[lastIndex].selectedAnswer,
            isCorrect: session.completedQuestions[lastIndex].isCorrect,
            timeSpent: session.completedQuestions[lastIndex].timeSpent,
            explanationRead: showExplanation,
            completedAt: session.completedQuestions[lastIndex].completedAt
        )
        currentSession = session
    }
    
    // MARK: - Time Tracking
    
    private func calculateTimeSpent() -> TimeInterval {
        guard let startTime = questionStartTime else {
            #if DEBUG
            assertionFailure("questionStartTime should be set before calculating time")
            #endif
            questionStartTime = Date()
            return 0
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        // Clamp to max interval to handle backgrounded app
        return min(elapsed, maxQuestionTimeInterval)
    }
    
    // MARK: - Session Finalization
    
    @MainActor
    private func finalizeSession() async {
        guard let session = currentSession else { return }
        
        let completedSession = session.markCompleted()
        currentSession = completedSession
        
        let result = TrainingResult(
            id: UUID(),
            sessionId: session.id,
            categoryName: session.categoryName,
            totalQuestions: session.completedQuestions.count,
            correctAnswers: session.correctAnswerCount,
            scorePercentage: session.scorePercentage,
            averageTimePerQuestion: session.averageTimePerQuestion,
            completedAt: Date(),
            failedQuestionIds: session.completedQuestions
                .filter { !$0.isCorrect }
                .map(\.questionId)
        )
        
        sessionResult = result
        await persistSessionResult()
    }
    
    @MainActor
    private func persistSessionResult() async {
        guard let result = sessionResult else { return }
        
        do {
            try sessionManager.saveTrainingResult(result)
        } catch {
            errorMessage = TrainingModeError.persistenceFailed(error.localizedDescription).localizedDescription
        }
    }
}
