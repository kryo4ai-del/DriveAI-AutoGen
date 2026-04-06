final class MockQuestionRepository: QuestionRepository {
    var mockQuestion: Question?
    var mockError: Error?
    
    func fetchQuestion(id: UUID) async throws -> Question {
        if let error = mockError { throw error }
        return mockQuestion ?? .stub()
    }
    
    func fetchQuestionsByCategory(categoryId: UUID) async throws -> [Question] {
        return [mockQuestion ?? .stub()]
    }
}