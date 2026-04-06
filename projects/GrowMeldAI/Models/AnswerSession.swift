// Models/AnswerSession.swift
import Foundation
import Combine

class AnswerSession: ObservableObject {
    @Published var answers: [String: String] = [:]  // questionId -> answerId

    func recordAnswer(questionId: String, answerId: String) {
        answers[questionId] = answerId
    }

    func getAnswer(for questionId: String) -> String? {
        answers[questionId]
    }

    func hasAnswered(_ questionId: String) -> Bool {
        answers[questionId] != nil
    }

    func isCorrect(_ questionId: String, correctAnswerId: String) -> Bool {
        answers[questionId] == correctAnswerId
    }

    func scoreCount(against questions: [QuizQuestion]) -> (correct: Int, total: Int) {
        let correct = questions.filter { isCorrect($0.id, correctAnswerId: $0.correctAnswerId) }.count
        return (correct: correct, total: questions.count)
    }

    func clearAll() {
        answers.removeAll()
    }
}

// MARK: - Minimal QuizQuestion model (used by AnswerSession.scoreCount)
struct QuizQuestion: Identifiable {
    let id: String
    let text: String
    let correctAnswerId: String
    let answers: [QuizAnswer]
}

struct QuizAnswer: Identifiable {
    let id: String
    let text: String
}