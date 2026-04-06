// Models/Shared/SessionScoring.swift
import Foundation

struct SessionScore {
    let correctCount: Int
    let totalCount: Int
    
    var percentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(correctCount) / Double(totalCount) * 100
    }
    
    var isPassed(threshold: Double = 0.80) -> Bool {
        percentage >= threshold * 100
    }
    
    var formattedPercentage: String {
        String(format: "%.0f%%", percentage)
    }
}

// Helper protocol for sessions
protocol ScoringSession {
    var questions: [Question] { get }
    var answers: [Int?] { get }
    
    func calculateScore() -> SessionScore
}

extension ScoringSession {
    func calculateScore() -> SessionScore {
        let correct = answers.enumerated()
            .filter { $0.offset < questions.count && questions[$0.offset].isAnswerCorrect($0.element ?? -1) }
            .count
        return SessionScore(correctCount: correct, totalCount: questions.count)
    }
}

// Conform both session types
extension ExamSession: ScoringSession {}
extension QuestionSession: ScoringSession {}

// Usage

// In ResultsView
Text("Score: \(session.currentScore.formattedPercentage)")