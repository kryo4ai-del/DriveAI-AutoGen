// Models/Session/QuizSession.swift
import Foundation

struct QuizSession: Identifiable {
    let id: UUID = UUID()
    let sessionID: UUID
    let type: SessionType
    let categoryID: String
    let startTime: Date
    let answers: [String: UserAnswer]
    let currentQuestionIndex: Int
    let questions: [Question]
    let isActive: Bool
    let timeLimit: Int?  // seconds, only for exam
    
    enum SessionType {
        case practice
        case exam
    }
    
    // MARK: - Computed Properties
    var elapsedSeconds: Int {
        Int(Date().timeIntervalSince(startTime))
    }
    
    var remainingTimeSeconds: Int? {
        guard let limit = timeLimit else { return nil }
        let remaining = limit - elapsedSeconds
        return max(0, remaining)
    }
    
    var isTimeExpired: Bool {
        guard let remaining = remainingTimeSeconds else { return false }
        return remaining <= 0
    }
    
    var progressPercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count) * 100
    }
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var score: Int {
        answers.values.filter { $0.isCorrect }.count
    }
    
    var scorePercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(score) / Double(questions.count) * 100
    }
    
    var passedExam: Bool {
        scorePercentage >= 90  // 90% pass threshold
    }
    
    // MARK: - Builders (Return new instances)
    func withAnswer(_ answer: UserAnswer) -> Self {
        var updated = self
        updated.answers[answer.id.uuidString] = answer
        return updated
    }
    
    func advanced() -> Self {
        var updated = self
        updated.currentQuestionIndex = min(currentQuestionIndex + 1, questions.count - 1)
        return updated
    }
    
    func ended() -> Self {
        var updated = self
        updated.isActive = false
        return updated
    }
    
    // MARK: - Initialization
    init(
        sessionID: UUID,
        type: SessionType,
        categoryID: String,
        startTime: Date,
        answers: [String: UserAnswer] = [:],
        currentQuestionIndex: Int = 0,
        questions: [Question] = [],
        isActive: Bool = true,
        timeLimit: Int? = nil
    ) {
        self.sessionID = sessionID
        self.type = type
        self.categoryID = categoryID
        self.startTime = startTime
        self.answers = answers
        self.currentQuestionIndex = currentQuestionIndex
        self.questions = questions
        self.isActive = isActive
        self.timeLimit = timeLimit ?? (type == .exam ? 3600 : nil)  // 60 min for exam
    }
}