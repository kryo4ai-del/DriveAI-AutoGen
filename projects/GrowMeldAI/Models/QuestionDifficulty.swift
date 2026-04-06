// Models/Domain.swift
import Foundation

// MARK: - Enums

enum QuestionDifficulty: Int, Codable, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3
    
    var label: String {
        switch self {
        case .easy: return "Leicht"
        case .medium: return "Mittel"
        case .hard: return "Schwer"
        }
    }
}

// Enum AnswerState declared in Models/AnswerState.swift

enum ExamSessionState: String, Codable {
    case inProgress
    case paused
    case completed
    case failed
}

// MARK: - Question & Options

// Struct QuestionOption declared in Models/QuestionOption.swift

// MARK: - Category

// MARK: - Exam Session

// MARK: - User Progress

// MARK: - Answer

// MARK: - User
