// SOURCE/Models/QuizProgress.swift
import Foundation

struct QuizProgress: Codable {
    var answeredQuestions: [AnsweredQuestion]
    var totalScore: Int
    var totalQuestions: Int
    var startDate: Date
    var endDate: Date?
    var categoryStats: [QuestionCategory: CategoryStats]

    struct AnsweredQuestion: Codable {
        let questionId: String
        let selectedAnswerIndex: Int
        let isCorrect: Bool
        let timestamp: Date
    }

    struct CategoryStats: Codable {
        var correctCount: Int
        var totalCount: Int
    }

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(totalScore) / Double(totalQuestions) * 100
    }

    var examReadiness: ExamReadiness {
        let readiness = min(accuracy / 78.0, 1.0) // 78% is passing threshold
        return ExamReadiness(value: readiness)
    }

    struct ExamReadiness {
        let value: Double

        var localizedDescription: String {
            switch value {
            case ..<0.3: return "Du hast noch viel zu lernen. Keine Sorge — wir helfen dir!"
            case ..<0.6: return "Gut gemacht! Mit etwas mehr Übung wirst du bereit sein."
            case ..<0.8: return "Fast geschafft! Du bist auf einem guten Weg."
            case ..<1.0: return "Sehr gut! Du bist fast bereit für die Prüfung."
            default: return "Herzlichen Glückwunsch! Du bist bereit für die Prüfung."
            }
        }
    }
}