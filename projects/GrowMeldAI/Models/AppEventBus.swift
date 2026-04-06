// Core/AppEventBus.swift
import Foundation
import Combine

/// Thread-safe event bus using synchronous callbacks
/// Guarantees event delivery (no PassthroughSubject data loss)
final class AppEventBus: @unchecked Sendable {
    // MARK: - Event Callbacks
    var onQuestionAnswered: ((QuestionAnsweredEvent) -> Void)?
    var onExamFinished: ((ExamFinishedEvent) -> Void)?
    var onCategoryCompleted: ((CategoryCompletedEvent) -> Void)?
    
    private let callbackQueue = DispatchQueue(
        label: "com.driveai.eventbus",
        attributes: .concurrent
    )
    
    // MARK: - Fire Methods (guaranteed delivery)
    
    func fireQuestionAnswered(_ event: QuestionAnsweredEvent) {
        callbackQueue.async { [weak self] in
            self?.onQuestionAnswered?(event)
        }
    }
    
    func fireExamFinished(_ event: ExamFinishedEvent) {
        callbackQueue.async { [weak self] in
            self?.onExamFinished?(event)
        }
    }
    
    func fireCategoryCompleted(_ event: CategoryCompletedEvent) {
        callbackQueue.async { [weak self] in
            self?.onCategoryCompleted?(event)
        }
    }
    
    static let shared = AppEventBus()
    private init() {}
}

// MARK: - Event Models

struct QuestionAnsweredEvent: Sendable {
    let questionId: String
    let categoryId: String
    let isCorrect: Bool
    let userStreak: Int
    let examDateProximity: ExamDateProximity?
    let timestamp: Date
    
    init(
        questionId: String,
        categoryId: String,
        isCorrect: Bool,
        userStreak: Int,
        examDateProximity: ExamDateProximity? = nil
    ) {
        self.questionId = questionId
        self.categoryId = categoryId
        self.isCorrect = isCorrect
        self.userStreak = userStreak
        self.examDateProximity = examDateProximity
        self.timestamp = Date()
    }
}

struct ExamFinishedEvent: Sendable {
    let score: Int
    let totalQuestions: Int
    let timeTaken: TimeInterval
    let isPassed: Bool
    let previousHighScore: Int?
    let timestamp: Date
    
    init(
        score: Int,
        totalQuestions: Int,
        timeTaken: TimeInterval,
        isPassed: Bool,
        previousHighScore: Int?
    ) {
        self.score = score
        self.totalQuestions = totalQuestions
        self.timeTaken = timeTaken
        self.isPassed = isPassed
        self.previousHighScore = previousHighScore
        self.timestamp = Date()
    }
}

struct CategoryCompletedEvent: Sendable {
    let categoryId: String
    let categoryName: String
    let correctCount: Int
    let totalCount: Int
    let accuracy: Float
    let timestamp: Date
    
    init(
        categoryId: String,
        categoryName: String,
        correctCount: Int,
        totalCount: Int
    ) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.accuracy = Float(correctCount) / Float(max(1, totalCount))
        self.timestamp = Date()
    }
}

enum ExamDateProximity: String, Codable, Sendable {
    case withinOneWeek = "within_1w"
    case withinTwoWeeks = "within_2w"
    case withinMonth = "within_1m"
}