public protocol QuestionDataSource: Sendable {  // More semantic
    func fetchQuestion(id: String) async throws -> Question
}