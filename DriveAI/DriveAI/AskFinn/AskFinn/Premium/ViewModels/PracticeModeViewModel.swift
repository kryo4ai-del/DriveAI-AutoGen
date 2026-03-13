import Foundation
import SwiftUI

// MARK: - State Models

struct QuestionUIState {
    let question: PremiumQuestion
    var selectedIndex: Int?
    var showFeedback: Bool = false
    
    var isAnswered: Bool { selectedIndex != nil }
    var isCorrect: Bool { selectedIndex == question.correctIndex }
}

struct SessionUIState {
    var currentIndex: Int = 0
    let totalQuestions: Int
    var correctCount: Int = 0
    var sessionStartTime: Date
    
    var progressPercent: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalQuestions)
    }
    
    var timeElapsed: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }
}

enum PracticeModeNavigation {
    case showQuestion(index: Int)
    case showFeedback(isCorrect: Bool)
    case showSessionEnd(PracticeSessionResult)
}

// MARK: - ViewModel

@MainActor
class PracticeModeViewModel: ObservableObject {
    @Published var questionState: QuestionUIState?
    @Published var sessionState: SessionUIState?
    @Published var navigationState: PracticeModeNavigation?
    @Published var error: PremiumDataServiceError?
    @Published var isLoading: Bool = false
    
    private let dataService: PremiumDefaultLocalDataService
    private var questions: [PremiumQuestion] = []
    private var session: PracticeSession?
    
    init(dataService: PremiumDefaultLocalDataService = .shared) {
        self.dataService = dataService
    }
    
    // MARK: - Public Methods
    
    func loadSession(categoryId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let questions = try await dataService.fetchQuestions(for: categoryId)
            guard !questions.isEmpty else {
                throw PremiumDataServiceError.categoryNotFound(categoryId)
            }
            
            self.questions = questions
            self.session = PracticeSession(
                id: UUID(),
                categoryId: categoryId,
                startedAt: Date(),
                currentQuestionIndex: 0,
                answers: [:],
                isActive: true
            )
            
            sessionState = SessionUIState(
                totalQuestions: questions.count,
                sessionStartTime: Date()
            )
            
            await loadCurrentQuestion(questions[0])
        } catch let error as PremiumDataServiceError {
            self.error = error
        } catch {
            self.error = .corruptedData("Unerwarteter Fehler: \(error.localizedDescription)")
        }
    }
    
    func resumeSession(_ sessionId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let session = try await dataService.loadSession(sessionId) else {
                throw PremiumDataServiceError.categoryNotFound(sessionId.uuidString)
            }
            
            self.session = session
            let questions = try await dataService.fetchQuestions(for: session.categoryId)
            self.questions = questions
            
            let correctCount = session.answers.values.filter { $0.isCorrect }.count
            sessionState = SessionUIState(
                currentIndex: session.currentQuestionIndex,
                totalQuestions: questions.count,
                correctCount: correctCount,
                sessionStartTime: session.startedAt
            )
            
            guard session.currentQuestionIndex < questions.count else {
                throw PremiumDataServiceError.questionNotFound("index-\(session.currentQuestionIndex)")
            }
            
            await loadCurrentQuestion(questions[session.currentQuestionIndex])
        } catch let error as PremiumDataServiceError {
            self.error = error
        } catch {
            self.error = .corruptedData("Fehler beim Laden der Sitzung: \(error.localizedDescription)")
        }
    }
    
    func selectAnswer(_ index: Int) async {
        guard let question = questionState?.question,
              var currentSession = session else { return }
        
        let isCorrect = index == question.correctIndex
        
        questionState?.selectedIndex = index
        questionState?.showFeedback = true
        
        currentSession.answers[question.id] = PracticeSession.SelectedAnswer(
            questionId: question.id,
            selectedIndex: index,
            isCorrect: isCorrect,
            timestamp: Date()
        )
        session = currentSession
        
        if isCorrect {
            sessionState?.correctCount += 1
        }
        
        navigationState = .showFeedback(isCorrect: isCorrect)
        
        await saveSession()
    }
    
    func nextQuestion() async {
        guard let sessionState = sessionState,
              sessionState.currentIndex < sessionState.totalQuestions - 1 else { return }
        
        let nextIndex = sessionState.currentIndex + 1
        self.sessionState?.currentIndex = nextIndex
        session?.currentQuestionIndex = nextIndex
        
        questionState = nil
        navigationState = .showQuestion(index: nextIndex)
        
        guard nextIndex < questions.count else { return }
        await loadCurrentQuestion(questions[nextIndex])
    }
    
    func previousQuestion() async {
        guard let sessionState = sessionState, sessionState.currentIndex > 0 else { return }
        
        let prevIndex = sessionState.currentIndex - 1
        self.sessionState?.currentIndex = prevIndex
        session?.currentQuestionIndex = prevIndex
        
        questionState = nil
        navigationState = .showQuestion(index: prevIndex)
        
        guard prevIndex < questions.count else { return }
        await loadCurrentQuestion(questions[prevIndex])
    }
    
    func skipQuestion() async {
        await nextQuestion()
    }
    
    func endSession() async -> PracticeSessionResult? {
        guard let session = session,
              let sessionState = sessionState else { return nil }
        
        let result = PracticeSessionResult(
            session: session,
            totalQuestions: sessionState.totalQuestions,
            timeSpent: sessionState.timeElapsed
        )
        
        var updatedSession = session
        updatedSession.isActive = false
        self.session = updatedSession
        await saveSession()
        
        navigationState = .showSessionEnd(result)
        return result
    }
    
    func saveSession() async {
        guard let session = session else { return }
        
        do {
            try await dataService.saveSession(session)
        } catch let error as PremiumDataServiceError {
            self.error = error
        } catch {
            self.error = .persistenceFailure("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadCurrentQuestion(_ question: PremiumQuestion) async {
        let hasAnswer = session?.answers[question.id] != nil
        
        questionState = QuestionUIState(
            question: question,
            selectedIndex: hasAnswer ? session?.answers[question.id]?.selectedIndex : nil,
            showFeedback: hasAnswer
        )
        
        navigationState = .showQuestion(index: sessionState?.currentIndex ?? 0)
    }
}
