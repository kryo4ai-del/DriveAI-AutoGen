// Models/ExamProgress.swift
import Foundation

struct ExamProgress: Codable, Sendable {
    let questionIDs: [String]
    let selectedAnswers: [Int?]
    let timeRemaining: Int
    let timestamp: Date
    
    init(questionIDs: [String], selectedAnswers: [Int?], timeRemaining: Int) {
        self.questionIDs = questionIDs
        self.selectedAnswers = selectedAnswers
        self.timeRemaining = timeRemaining
        self.timestamp = Date()
    }
}