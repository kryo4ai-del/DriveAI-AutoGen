import Foundation

class MockQuestionDataProvider: QuestionDataProvider {
    var mockQuestions: [GrowMeldAI.Question] = []
    var mockCategories: [GrowMeldAI.Category] = []
    var shouldThrow: ServiceError?

    func fetchQuestions(categoryId: Foundation.UUID) async throws -> [GrowMeldAI.Question] {
        if let error = shouldThrow { throw error }
        return mockQuestions.filter { $0.categoryId == categoryId }
    }

    func fetchExamSet() async throws -> [GrowMeldAI.Question] {
        if let error = shouldThrow { throw error }
        return Array(mockQuestions.shuffled().prefix(30))
    }

    func fetchQuestion(id: Foundation.UUID) async throws -> GrowMeldAI.Question {
        if let error = shouldThrow { throw error }
        guard let question = mockQuestions.first(where: { $0.id == id }) else {
            throw ServiceError.questionsNotFound
        }
        return question
    }

    func fetchCategories() async throws -> [GrowMeldAI.Category] {
        if let error = shouldThrow { throw error }
        return mockCategories
    }
}