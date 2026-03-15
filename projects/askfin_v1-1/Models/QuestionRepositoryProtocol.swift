// Features/ExamReadiness/Services/QuestionRepository.swift
import Foundation

protocol QuestionRepositoryProtocol {
    func loadQuestions() async throws -> [Question]
    func getQuestion(by id: String) async throws -> Question
    func getQuestions(by category: QuestionCategory) async throws -> [Question]
    func getRandomQuestions(count: Int) async throws -> [Question]
}

@MainActor

enum LocalDataError: LocalizedError {
    case fileNotFound
    case decodingFailed
    case questionNotFound
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound: return "Fragen-Datei nicht gefunden"
        case .decodingFailed: return "Fehler beim Laden der Fragen"
        case .questionNotFound: return "Frage nicht gefunden"
        }
    }
}

// Services/PersistenceService.swift
protocol PersistenceServiceProtocol {
    func saveExamSession(_ session: ExamSession) throws
    func loadExamSession(_ id: String) throws -> ExamSession?
    func loadAllExamSessions() throws -> [ExamSession]
    func saveUserProgress(_ progress: UserProgress) throws
    func loadUserProgress() throws -> UserProgress?
}

@MainActor

// Features/ExamReadiness/Services/ExamSessionService.swift
@MainActor
final class ExamSessionService {
    private let questionRepository: QuestionRepositoryProtocol
    private let persistenceService: PersistenceServiceProtocol
    private let progressService: ProgressTrackingService
    
    init(
        questionRepository: QuestionRepositoryProtocol,
        persistenceService: PersistenceServiceProtocol,
        progressService: ProgressTrackingService
    ) {
        self.questionRepository = questionRepository
        self.persistenceService = persistenceService
        self.progressService = progressService
    }
    
    func createExamSession(questionCount: Int = 30) async throws -> ExamSession {
        let questions = try await questionRepository.getRandomQuestions(count: questionCount)
        let session = ExamSession(
            id: UUID().uuidString,
            startTime: Date(),
            endTime: nil,
            answers: [:],
            score: nil,
            passed: nil,
            questionIds: questions.map { $0.id }
        )
        try persistenceService.saveExamSession(session)
        return session
    }
    
    func calculateScore(for session: ExamSession) async throws -> Int {
        var score = 0
        for (questionId, selectedAnswerIndex) in session.answers {
            let question = try await questionRepository.getQuestion(by: questionId)
            if question.correctAnswer == selectedAnswerIndex {
                score += 1
            }
        }
        return score
    }
    
    func completeExamSession(_ session: inout ExamSession) async throws {
        session.endTime = Date()
        let score = try await calculateScore(for: session)
        session.score = score
        session.passed = score >= 24 // 80% = 24/30
        
        try persistenceService.saveExamSession(session)
        try await progressService.updateProgressFromSession(session)
    }
}

// Features/ExamReadiness/Services/ProgressTrackingService.swift
@MainActor
final class ProgressTrackingService {
    private let persistenceService: PersistenceServiceProtocol
    private let questionRepository: QuestionRepositoryProtocol
    
    init(
        persistenceService: PersistenceServiceProtocol,
        questionRepository: QuestionRepositoryProtocol
    ) {
        self.persistenceService = persistenceService
        self.questionRepository = questionRepository
    }
    
    func loadProgress() throws -> UserProgress {
        if let progress = try persistenceService.loadUserProgress() {
            return progress
        }
        return UserProgress()
    }
    
    func updateProgressFromSession(_ session: ExamSession) async throws {
        var progress = try loadProgress()
        
        for (questionId, selectedAnswer) in session.answers {
            let question = try await questionRepository.getQuestion(by: questionId)
            let isCorrect = question.correctAnswer == selectedAnswer
            progress.recordAnswer(category: question.category, isCorrect: isCorrect)
        }
        
        try persistenceService.saveUserProgress(progress)
    }
    
    func recordQuestionAnswer(
        questionId: String,
        selectedAnswer: Int,
        isCorrect: Bool
    ) async throws {
        var progress = try loadProgress()
        let question = try await questionRepository.getQuestion(by: questionId)
        progress.recordAnswer(category: question.category, isCorrect: isCorrect)
        try persistenceService.saveUserProgress(progress)
    }
}