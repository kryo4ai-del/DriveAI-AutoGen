import Foundation

protocol DataService: Sendable {
    nonisolated func fetchAllCategories() async throws -> [GrowMeldCategory]
    nonisolated func fetchQuestions(for categoryID: String) async throws -> [GrowMeldQuestion]
    nonisolated func fetchQuestion(by id: String) async throws -> GrowMeldQuestion?
    nonisolated func fetchUserProgress() async throws -> GrowMeldUserProgress
    nonisolated func saveUserAnswer(_ answer: UserAnswer) async throws
    nonisolated func saveExamResult(_ result: ExamResult) async throws
}

final class MockDataService: DataService {
    var mockQuestions: [GrowMeldQuestion] = []
    var mockCategories: [GrowMeldCategory] = []
    private let _shouldFail = FailFlag()

    var shouldFail: Bool {
        get { _shouldFail.value }
        set { _shouldFail.value = newValue }
    }

    nonisolated func fetchAllCategories() async throws -> [GrowMeldCategory] {
        if _shouldFail.value { throw DataServiceError.mockError }
        return mockCategories
    }

    nonisolated func fetchQuestions(for categoryID: String) async throws -> [GrowMeldQuestion] {
        if _shouldFail.value { throw DataServiceError.mockError }
        return mockQuestions.filter { $0.categoryID == categoryID }
    }

    nonisolated func fetchQuestion(by id: String) async throws -> GrowMeldQuestion? {
        if _shouldFail.value { throw DataServiceError.mockError }
        return mockQuestions.first { $0.id == id }
    }

    nonisolated func fetchUserProgress() async throws -> GrowMeldUserProgress {
        if _shouldFail.value { throw DataServiceError.mockError }
        return GrowMeldUserProgress.empty
    }

    nonisolated func saveUserAnswer(_ answer: UserAnswer) async throws {
        if _shouldFail.value { throw DataServiceError.mockError }
    }

    nonisolated func saveExamResult(_ result: ExamResult) async throws {
        if _shouldFail.value { throw DataServiceError.mockError }
    }
}

private final class FailFlag: @unchecked Sendable {
    var value: Bool = false
}

struct GrowMeldCategory: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
}

struct GrowMeldQuestion: Codable, Identifiable, Sendable {
    let id: String
    let categoryID: String
    let text: String
    let options: [String]
    let correctOptionIndex: Int
}

struct GrowMeldUserProgress: Codable, Sendable {
    let answeredQuestionIDs: [String]
    let correctAnswerIDs: [String]

    static let empty = GrowMeldUserProgress(answeredQuestionIDs: [], correctAnswerIDs: [])
}

struct UserAnswer: Codable, Sendable {
    let questionID: String
    let selectedOptionIndex: Int
    let isCorrect: Bool
    let answeredAt: Date
}

struct ExamResult: Codable, Sendable {
    let id: String
    let score: Int
    let totalQuestions: Int
    let completedAt: Date
}

enum DataServiceError: LocalizedError {
    case categoryNotFound
    case questionNotFound
    case loadTimeout
    case mockError

    var errorDescription: String? {
        switch self {
        case .categoryNotFound:
            return "Category not found"
        case .questionNotFound:
            return "Question not found"
        case .loadTimeout:
            return "Data loading timed out"
        case .mockError:
            return "Mock error for testing"
        }
    }
}