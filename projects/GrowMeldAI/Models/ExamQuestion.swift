// ExamQuestion.swift
import Foundation

struct ExamQuestion: Identifiable, Codable, Equatable {
    let id: UUID
    let questionText: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let category: QuestionCategory
    let explanation: String
    let difficulty: DifficultyLevel
    let imageName: String?

    var allAnswers: [String] {
        [correctAnswer] + incorrectAnswers.shuffled()
    }

    enum QuestionCategory: String, CaseIterable, Codable {
        case trafficRules = "Verkehrsregeln"
        case signs = "Verkehrszeichen"
        case behavior = "Verhalten im Verkehr"
        case technical = "Technische Fragen"
        case environment = "Umwelt & Sicherheit"
    }

    enum DifficultyLevel: Int, Codable {
        case easy = 1
        case medium = 2
        case hard = 3
    }
}