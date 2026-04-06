// Services/ExamSimulationService.swift
import Foundation
import os.log

protocol ExamSimulationService: ObservableObject {
    var currentSession: ExamSession? { get }
    var timeRemaining: TimeInterval { get }
    var currentQuestionIndex: Int { get }
    var isTimerRunning: Bool { get }
    var currentQuestion: Question? { get }
    
    func startExam(questions: [Question]) async
    func selectAnswer(_ answerIndex: Int)
    func nextQuestion()
    func previousQuestion()
    func canGoNext() -> Bool
    func canGoPrevious() -> Bool
    func finishExam() async -> ExamResult
    func cancelExam()
}

@MainActor
final class ExamSimulationServiceImpl: ExamSimulationService {
    @Published var currentSession: ExamSession?
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentQuestionIndex: Int = 0
    @Published var isTimerRunning: Bool = false
    
    var currentQuestion: Question? {
        guard let session = currentSession,
              currentQuestionIndex < session.questions.count else {
            return nil
        }
        return session.questions[currentQuestionIndex]
    }
    
    private var timerTask: Task<Void, Never>?
    private let examTimeLimit: TimeInterval = 60 * 60 // 60 minutes
    private let logger = Logger(subsystem: "com.driveai", category: "ExamSimulation")
    
    func startExam(questions: [Question]) async {
        logger.info("Starting exam with \(questions.count) questions")
        
        let session = ExamSession(
            id: UUID().uuidString,
            startTime: Date(),
            questions: questions,
            userAnswers: Array(repeating: nil, count: questions.count)
        )
        self.currentSession = session
        self.timeRemaining = examTimeLimit
        self.currentQuestionIndex = 0
        self.isTimerRunning = true
        
        startTimer()
    }
    
    func selectAnswer(_ answerIndex: Int) {
        guard var session = currentSession,
              currentQuestionIndex < session.userAnswers.count else {
            logger.warning("Invalid answer selection at index \(self.currentQuestionIndex)")
            return
        }
        
        session.userAnswers[currentQuestionIndex] = answerIndex
        self.currentSession = session
        logger.debug("Selected answer \(answerIndex) for question \(self.currentQuestionIndex)")
    }
    
    func nextQuestion() {
        guard let session = currentSession else { return }
        if currentQuestionIndex < session.questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func canGoNext() -> Bool {
        guard let session = currentSession else { return false }
        return currentQuestionIndex < session.questions.count - 1
    }
    
    func canGoPrevious() -> Bool {
        currentQuestionIndex > 0
    }
    
    func finishExam() async -> ExamResult {
        guard var session = currentSession else {
            logger.error("No active exam session")
            fatalError("No active exam session")
        }
        
        isTimerRunning = false
        timerTask?.cancel()
        
        session.isComplete = true
        session.completionTime = examTimeLimit - timeRemaining
        
        let categoryBreakdown = calculateCategoryBreakdown(session: session)
        
        logger.info("Exam completed: \(session.score)/\(session.questions.count) points")
        
        let result = ExamResult(
            id: session.id,
            score: session.score,
            totalQuestions: session.questions.count,
            percentage: session.percentage,
            isPassed: session.isPassed,
            completionTime: session.completionTime,
            categoryBreakdown: categoryBreakdown,
            date: Date()
        )
        
        self.currentSession = nil
        return result
    }
    
    func cancelExam() {
        logger.info("Exam cancelled")
        isTimerRunning = false
        timerTask?.cancel()
        currentSession = nil
        currentQuestionIndex = 0
    }
    
    // MARK: - Private Helpers
    
    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while timeRemaining > 0 && isTimerRunning {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                timeRemaining -= 1
                
                if timeRemaining <= 0 {
                    isTimerRunning = false
                    logger.warning("⏰ Time limit exceeded")
                    break
                }
            }
        }
    }
    
    private func calculateCategoryBreakdown(session: ExamSession) -> [String: ExamResult.CategoryResult] {
        var breakdown: [String: ExamResult.CategoryResult] = [:]
        
        for category in Category.allCategories {
            let categoryQuestions = session.questions.filter { $0.categoryId == category.id }
            guard !categoryQuestions.isEmpty else { continue }
            
            let correctAnswers = zip(
                categoryQuestions,
                session.userAnswers
            ).filter { question, answer in
                answer == question.correctAnswerIndex
            }.count
            
            let percentage = Double(correctAnswers) / Double(categoryQuestions.count) * 100
            
            breakdown[category.id] = ExamResult.CategoryResult(
                categoryName: category.name,
                correct: correctAnswers,
                total: categoryQuestions.count,
                percentage: percentage
            )
        }
        
        return breakdown
    }
}