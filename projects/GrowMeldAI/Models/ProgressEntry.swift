// Models/ProgressEntry.swift
import Foundation

struct ProgressEntry: Codable {
    let id: String
    let userId: String
    let questionId: String
    let categoryId: String
    let isCorrect: Bool
    let attemptedAt: Date
    let timeTaken: TimeInterval
}