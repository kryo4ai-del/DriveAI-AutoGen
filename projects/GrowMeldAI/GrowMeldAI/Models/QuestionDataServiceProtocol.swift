import Foundation

protocol QuestionDataServiceProtocol {
    func getQuestion(id: UUID) async throws -> Question
    func getQuestionsByCategory(_ categoryId: UUID) async throws -> [Question]
    func getAllCategories() async throws -> [Category]
    func getRandomQuestions(count: Int, from categoryId: UUID?) async throws -> [Question]
}

@MainActor