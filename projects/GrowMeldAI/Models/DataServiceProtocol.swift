import Foundation

protocol DataServiceProtocol {
    func loadQuestions(category: String?) async throws -> [Question]
    func getQuestion(id: UUID) async throws -> Question?
    func getAllCategories() async throws -> [QuestionCategory]
    func loadUserProgress() async throws -> User
    func saveUserProgress(_ user: User) async throws
    func saveExamResult(_ result: ExamResult) async throws
    func getExamResults(limit: Int) async throws -> [ExamResult]
}
