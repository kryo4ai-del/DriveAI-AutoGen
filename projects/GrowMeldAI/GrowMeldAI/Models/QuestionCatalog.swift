// Services/Learning/QuestionCatalog.swift

import Foundation

protocol QuestionCatalog {
    func hasQuestions(for category: ExamCategory) -> Bool
    func getQuestionsCount(for category: ExamCategory) -> Int
    func getRemaining(for category: ExamCategory) -> Int
    func getAllCategories() -> [ExamCategory]
}

@MainActor
final class LocalQuestionCatalog: QuestionCatalog {
    private let questions: [ExamQuestion]
    private let answeredQuestionIds: Set<UUID>
    
    init(questions: [ExamQuestion] = [], answeredQuestionIds: Set<UUID> = []) {
        self.questions = questions
        self.answeredQuestionIds = answeredQuestionIds
    }
    
    func hasQuestions(for category: ExamCategory) -> Bool {
        questions.contains { $0.category == category }
    }
    
    func getQuestionsCount(for category: ExamCategory) -> Int {
        questions.filter { $0.category == category }.count
    }
    
    func getRemaining(for category: ExamCategory) -> Int {
        let categoryQuestions = questions.filter { $0.category == category }
        let remaining = categoryQuestions.filter { !answeredQuestionIds.contains($0.id) }
        return remaining.count
    }
    
    func getAllCategories() -> [ExamCategory] {
        Array(Set(questions.map { $0.category })).sorted { $0.localizedName < $1.localizedName }
    }
}

// Mock implementation for testing
final class MockQuestionCatalog: QuestionCatalog {
    var mockQuestions: [ExamQuestion] = []
    var mockAnswered: Set<UUID> = []
    
    func hasQuestions(for category: ExamCategory) -> Bool {
        mockQuestions.contains { $0.category == category }
    }
    
    func getQuestionsCount(for category: ExamCategory) -> Int {
        mockQuestions.filter { $0.category == category }.count
    }
    
    func getRemaining(for category: ExamCategory) -> Int {
        let categoryQuestions = mockQuestions.filter { $0.category == category }
        let remaining = categoryQuestions.filter { !mockAnswered.contains($0.id) }
        return remaining.count
    }
    
    func getAllCategories() -> [ExamCategory] {
        Array(Set(mockQuestions.map { $0.category }))
    }
}

// Supporting model