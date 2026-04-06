// Data access layer
protocol QuestionRepositoryProtocol {
    func fetchQuestions(category: QuestionCategory?) async throws -> [Question]
    func fetchQuestion(id: String) async throws -> Question
}

// Business logic layer