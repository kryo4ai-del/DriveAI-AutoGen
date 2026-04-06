// DriveAI/Features/TrialMechanik/Domain/Models/SessionMetrics.swift
import Foundation

struct SessionMetrics: Codable, Equatable {
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var categoryCoverage: [String: Int] = [:] // category -> count

    var accuracyPercent: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestionsAnswered) * 100
    }

    mutating func recordAnswer(correct: Bool, category: String) {
        totalQuestionsAnswered += 1
        if correct {
            correctAnswers += 1
        }
        categoryCoverage[category, default: 0] += 1
    }
}