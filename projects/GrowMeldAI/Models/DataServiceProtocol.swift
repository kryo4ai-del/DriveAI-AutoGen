import Foundation

protocol DataServiceProtocol {
    func loadQuestions(category: String?) async throws -> [GrowMeldQuestion]
    func getQuestion(id: UUID) async throws -> GrowMeldQuestion?
    func getAllCategories() async throws -> [GrowMeldQuestionCategory]
    func loadUserProgress() async throws -> GrowMeldUser
    func saveUserProgress(_ user: GrowMeldUser) async throws
    func saveExamResult(_ result: GrowMeldExamResult) async throws
    func getExamResults(limit: Int) async throws -> [GrowMeldExamResult]
}

struct GrowMeldQuestion: Codable, Identifiable {
    let id: UUID
    let text: String
    let category: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String?
}

struct GrowMeldQuestionCategory: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
}

struct GrowMeldUser: Codable, Identifiable {
    let id: UUID
    var name: String
    var totalQuestionsAnswered: Int
    var correctAnswers: Int
    var lastActiveDate: Date
}

struct GrowMeldExamResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let score: Int
    let totalQuestions: Int
    let category: String?
}