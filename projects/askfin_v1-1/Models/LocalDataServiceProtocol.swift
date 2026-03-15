import Foundation

protocol LocalDataServiceProtocol: AnyObject {
    func fetchAllQuestions() async throws -> [Question]
    func fetchQuestionsByCategory(_ categoryId: String) async throws -> [Question]
    func fetchCategory(byId: String) async throws -> QuestionCategory?
}

struct QuestionCategory: Identifiable, Codable {
    let id: String
    let name: String
}