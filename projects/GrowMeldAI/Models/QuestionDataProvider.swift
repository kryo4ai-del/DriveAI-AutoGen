import Foundation

protocol QuestionDataProvider: Sendable {
    func fetchQuestions(categoryId: UUID) async throws -> [Question]
}