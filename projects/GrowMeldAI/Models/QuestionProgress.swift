// Data/Models/QuestionProgress.swift
import Foundation
struct QuestionProgress: Codable, Identifiable {
    let id: String
    let questionId: String
    let answered: Bool
    let isCorrect: Bool
    let answeredAt: Date
    let nextReviewDate: Date?
    let repetitionCount: Int = 0
    let difficulty: Double = 0.5  // 0 = hard, 1 = easy (SM-2)
    
    enum CodingKeys: String, CodingKey {
        case id, questionId, answered, isCorrect, answeredAt, nextReviewDate, repetitionCount, difficulty
    }
}