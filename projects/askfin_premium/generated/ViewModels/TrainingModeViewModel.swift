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
            self.allQuestionsForSession = questions.shuffled() // ✓ Randomize order
            
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
        
        // ✓ Reset UI state for new question
        selectedAnswer = nil
        showExplanation = false
        questionStartTime = Date()
        
        // Safety assertion
        #if DEBUG
        assert(questionStartTime != nil, "questionStartTime must be set")
        #endif
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
        
        // ✓ Navigate back WITHOUT deleting answer
        // User can review or change answer
        await loadQuestion(at: previousIndex)
    }
    
    @MainActor
    func skipQuestion() async {
        guard let session = currentSession,
              let question = currentQuestion else { return }
        
        let timeSpent = calculateTimeSpent()
        
        let completedQuestion = CompletedQuestion(
            questionId: question.question.id,
            selectedAnswer: "", // Skipped
            isCorrect: false,
            timeSpent: timeSpent,
            explanationRead: false
        )
        
        let updatedSession = session.withCompletedQuestion(completedQuestion)
        currentSession = updatedSession
        
        await nextQuestion()
    }
    
    // MARK: - Answer Submission (Race Condition Prevention)
    
    @MainActor
    func submitAnswer(_ selectedOption: String) async {
        // ✓ Guard against rapid submissions
        guard !selectedOption.isEmpty else {
            errorMessage = TrainingModeError.invalidAnswerSelection.localizedDescription
            return
        }
        
        guard let session = currentSession,
              let question = currentQuestion else { return }
        
        // ✓ Prevent double-submission: check if already answered
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
        
        // ✓ Use pure function for immutable update
        let updatedSession = session.withCompletedQuestion(completedQuestion)
        currentSession = updatedSession
        
        // ✓ Auto-advance is UI concern, NOT ViewModel
        // View will call nextQuestion() after user taps "Continue"
    }
    
    @MainActor
    func toggleExplanation() {
        showExplanation.toggle()
        
        // Mark explanation as read in completed question
        guard var session = currentSession,
              session.completedQuestions.count > 0 else { return }
        
        let lastIndex = session.completedQuestions.count - 1
        session.completedQuestions[lastIndex].explanationRead = showExplanation
        currentSession = session
    }
    
    // MARK: - Time Tracking (With Bounds)
    
    private func calculateTimeSpent() -> TimeInterval {
        guard let startTime = questionStartTime else {
            #if DEBUG
            assertionFailure("questionStartTime should be set before calculating time")
            #endif
            // Fallback in production
            questionStartTime = Date()
            return 0
        }


Based on the refactored implementation, I'm generating **production-ready test cases** organized by component and behavior.

---
