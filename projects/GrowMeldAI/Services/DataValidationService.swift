import Foundation

@MainActor
protocol DataValidationService {
    func validateQuestion(_ question: GrowMeldQuestion) throws
    func validateUserProfile(_ profile: GrowMeldUserProfile) throws
    func validateExamResult(_ result: GrowMeldExamResult) throws
}

struct GrowMeldQuestion {
    let id: String
    let text: String
    let options: [String]
    let correctOptionIndex: Int
    let categoryId: String
}

struct GrowMeldUserProfile {
    let id: String
    let name: String
    let email: String
}

struct GrowMeldExamResult {
    let id: String
    let userId: String
    let score: Int
    let totalQuestions: Int
    let completedAt: Date
}

enum DataValidationError: LocalizedError {
    case invalidQuestion(reason: String)
    case invalidUserProfile(reason: String)
    case invalidExamResult(reason: String)

    var errorDescription: String? {
        switch self {
        case .invalidQuestion(let reason):
            return "Invalid question: \(reason)"
        case .invalidUserProfile(let reason):
            return "Invalid user profile: \(reason)"
        case .invalidExamResult(let reason):
            return "Invalid exam result: \(reason)"
        }
    }
}

@MainActor
final class DefaultDataValidationService: DataValidationService {

    func validateQuestion(_ question: GrowMeldQuestion) throws {
        guard !question.id.isEmpty else {
            throw DataValidationError.invalidQuestion(reason: "ID must not be empty")
        }
        guard !question.text.isEmpty else {
            throw DataValidationError.invalidQuestion(reason: "Text must not be empty")
        }
        guard !question.options.isEmpty else {
            throw DataValidationError.invalidQuestion(reason: "Options must not be empty")
        }
        guard question.correctOptionIndex >= 0 && question.correctOptionIndex < question.options.count else {
            throw DataValidationError.invalidQuestion(reason: "Correct option index out of range")
        }
        guard !question.categoryId.isEmpty else {
            throw DataValidationError.invalidQuestion(reason: "Category ID must not be empty")
        }
    }

    func validateUserProfile(_ profile: GrowMeldUserProfile) throws {
        guard !profile.id.isEmpty else {
            throw DataValidationError.invalidUserProfile(reason: "ID must not be empty")
        }
        guard !profile.name.isEmpty else {
            throw DataValidationError.invalidUserProfile(reason: "Name must not be empty")
        }
        guard !profile.email.isEmpty else {
            throw DataValidationError.invalidUserProfile(reason: "Email must not be empty")
        }
    }

    func validateExamResult(_ result: GrowMeldExamResult) throws {
        guard !result.id.isEmpty else {
            throw DataValidationError.invalidExamResult(reason: "ID must not be empty")
        }
        guard !result.userId.isEmpty else {
            throw DataValidationError.invalidExamResult(reason: "User ID must not be empty")
        }
        guard result.totalQuestions > 0 else {
            throw DataValidationError.invalidExamResult(reason: "Total questions must be greater than zero")
        }
        guard result.score >= 0 && result.score <= result.totalQuestions else {
            throw DataValidationError.invalidExamResult(reason: "Score out of valid range")
        }
    }
}