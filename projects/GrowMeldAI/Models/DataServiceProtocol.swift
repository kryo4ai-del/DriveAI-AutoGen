import Foundation

protocol DataServiceProtocol {
    func loadQuestions(category: String?) async throws -> [GrowMeldQuestion]
    func getQuestion(id: UUID) async throws -> GrowMeldQuestion?
    func getAllCategories() async throws -> [QuestionCategory]
    func loadUserProgress() async throws -> User
    func saveUserProgress(_ user: User) async throws
    func saveExamResult(_ result: GrowMeldExamResult) async throws
    func getExamResults(limit: Int) async throws -> [GrowMeldExamResult]
}