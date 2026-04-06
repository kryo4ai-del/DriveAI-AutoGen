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

enum AnswerState: String, Codable, CaseIterable {
    case unanswered
    case selected
    case submitted
    case correct
    case incorrect
}

enum ExamSessionState: String, Codable {
    case inProgress
    case paused
    case completed
    case failed
}

// MARK: - Question & Options

struct QuestionOption: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let imageUrl: String?
    
    init(id: UUID = UUID(), text: String, imageUrl: String? = nil) {
        self.id = id
        self.text = text
        self.imageUrl = imageUrl
    }
}

// MARK: - Category

// MARK: - Exam Session

// MARK: - User Progress

// MARK: - Answer

// MARK: - User
