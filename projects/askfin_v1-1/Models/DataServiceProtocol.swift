import Foundation

protocol DataServiceProtocol {
    func fetchAllQuestions() async throws -> [Question]
    func fetchUserAnswerHistory() async throws -> [UserAnswer]
    func fetchCategoryQuestions(for categoryId: String) async throws -> [Question]
}

protocol ExamDateManageable {
    func daysUntilExam() -> Int?
    func examDate() -> Date?
    func setExamDate(_ date: Date)
}

// MARK: - Core Models for Protocol Compliance

struct UserAnswer: Codable {
    let questionId: String
    let selectedAnswerIndex: Int
    let isCorrect: Bool
    let answeredAt: Date
}

struct Category: Identifiable, Codable {
    let id: String
    let name: String
    let description: String?
}