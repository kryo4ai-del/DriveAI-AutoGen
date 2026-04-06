// Tests/Mocks/MockQuestionDataProvider.swift
class MockQuestionDataProvider: QuestionDataProvider {
    var mockQuestions: [Question] = []
    var mockCategories: [Category] = []
    var shouldThrow: ServiceError?
    
    func fetchQuestions(categoryId: UUID) async throws -> [Question] {
        if let error = shouldThrow { throw error }
        return mockQuestions.filter { $0.categoryId == categoryId }
    }
    
    func fetchExamSet() async throws -> [Question] {
        if let error = shouldThrow { throw error }
        return Array(mockQuestions.shuffled().prefix(30))
    }
    
    func fetchQuestion(id: UUID) async throws -> Question {
        if let error = shouldThrow { throw error }
        guard let question = mockQuestions.first(where: { $0.id == id }) else {
            throw ServiceError.questionsNotFound
        }
        return question
    }
    
    func fetchCategories() async throws -> [Category] {
        if let error = shouldThrow { throw error }
        return mockCategories
    }
}