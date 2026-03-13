// ExamQuestion.swift
// Exam-simulation-specific question model.
//
// Separate from Training Mode's SessionQuestion to avoid cross-pillar coupling.
// SessionQuestion uses swipe-based AnswerOption with failable init;
// ExamQuestion uses simple String options with Codable support for persistence.

import Foundation

struct ExamQuestion: Identifiable, Codable {
    let id: UUID
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
    let topic: TopicArea
    let questionType: QuestionType
    let fehlerpunkteCategory: FehlerpunkteCategory
    let explanation: String?
}
