import Foundation

enum DTOMapper {

    static func mapQuestion(_ dto: RawQuestionDTO) throws -> QuizQuestion {
        let answers = try dto.answers.map(mapAnswer)
        return QuizQuestion(
            id: UUID(uuidString: dto.id ?? "") ?? UUID(),
            categoryID: UUID(uuidString: dto.categoryID) ?? UUID(),
            text: dto.text,
            imageURL: dto.imageURL.flatMap(URL.init(string:)),
            answers: answers,
            correctAnswerID: UUID(uuidString: dto.correctAnswerID) ?? UUID(),
            explanation: dto.explanation,
            difficulty: ExamDifficulty(rawValue: dto.difficulty ?? "medium") ?? .medium
        )
    }

    static func mapAnswer(_ dto: RawAnswerDTO) throws -> QuizAnswer {
        QuizAnswer(
            id: UUID(uuidString: dto.id ?? "") ?? UUID(),
            text: dto.text,
            isCorrect: dto.isCorrect
        )
    }

    static func mapCategory(_ dto: RawCategoryDTO) throws -> QuizCategory {
        QuizCategory(
            id: UUID(uuidString: dto.id ?? "") ?? UUID(),
            name: dto.name,
            description: dto.description,
            icon: dto.icon,
            order: dto.order ?? 0
        )
    }
}

// MARK: - Raw DTO Types

struct RawQuestionDTO: Codable {
    let id: String?
    let categoryID: String
    let text: String
    let imageURL: String?
    let answers: [RawAnswerDTO]
    let correctAnswerID: String
    let explanation: String?
    let difficulty: String?
}

struct RawAnswerDTO: Codable {
    let id: String?
    let text: String
    let isCorrect: Bool
}

struct RawCategoryDTO: Codable {
    let id: String?
    let name: String
    let description: String?
    let icon: String?
    let order: Int?
}

// MARK: - Domain Types

enum ExamDifficulty: String, Codable {
    case easy
    case medium
    case hard
}

struct QuizAnswer: Identifiable, Codable {
    let id: UUID
    let text: String
    let isCorrect: Bool
}

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let categoryID: UUID
    let text: String
    let imageURL: URL?
    let answers: [QuizAnswer]
    let correctAnswerID: UUID
    let explanation: String?
    let difficulty: ExamDifficulty
}

struct QuizCategory: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String?
    let icon: String?
    let order: Int
}