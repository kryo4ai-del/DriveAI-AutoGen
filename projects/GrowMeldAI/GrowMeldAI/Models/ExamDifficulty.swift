// Domain/Entities.swift

import Foundation

// MARK: - Type-Safe IDs
typealias QuestionID = UUID
typealias CategoryID = UUID
typealias AnswerID = UUID
typealias UserSessionID = UUID

// MARK: - Enums
enum ExamDifficulty: String, Codable, Sendable {
    case easy
    case medium
    case hard
}
