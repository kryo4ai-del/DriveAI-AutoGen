import Foundation

protocol QuestionRepository {
    func fetchAllQuestions() async throws -> [Question]
    func fetchQuestions(forCategoryId: Int) async throws -> [Question]
    func fetchRandomQuestions(count: Int, categoryId: Int?) async throws -> [Question]
    func searchQuestions(query: String) async throws -> [Question]
}