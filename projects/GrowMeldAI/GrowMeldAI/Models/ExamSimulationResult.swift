// Models/ExamSimulationResult.swift
struct ExamSimulationResult: Codable {
    let id: UUID
    let timestamp: Date
    let duration: TimeInterval
    let score: Int
    let totalQuestions: Int
    var passed: Bool { score >= passingScore }
    
    let questionResults: [QuestionAttemptRecord]
    let categoryBreakdown: [CategoryAttemptSummary]
    
    var passingScore: Int = 20 // 66.7% of 30
}

struct CategoryAttemptSummary: Codable {
    let categoryId: String
    let correctCount: Int
    let totalCount: Int
}