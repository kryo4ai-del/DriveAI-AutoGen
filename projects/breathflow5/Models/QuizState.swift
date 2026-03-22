// MARK: - Features/Quiz/Models/QuizState.swift
import Foundation

/// Single source of truth for quiz session state
struct QuizState: Equatable, Sendable {
    var currentIndex: Int = 0
    var selectedAnswerIndex: Int?
    var userAnswers: [Int?] = []
    var questions: [Question] = []
    var isLoading: Bool = false
    var error: QuestionRepositoryError?
    var isComplete: Bool = false
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }
    
    var isAnswered: Bool {
        selectedAnswerIndex != nil
    }
    
    mutating func selectAnswer(_ index: Int) {
        selectedAnswerIndex = index
    }
    
    mutating func submitAnswer() {
        guard let selected = selectedAnswerIndex else { return }
        userAnswers.append(selected)
        selectedAnswerIndex = nil
        currentIndex += 1
        isComplete = currentIndex >= questions.count
    }
    
    mutating func reset() {
        self = QuizState()
    }
}