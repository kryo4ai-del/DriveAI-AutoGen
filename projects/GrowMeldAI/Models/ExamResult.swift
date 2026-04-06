import Foundation

/// Persisted result from a 30-question exam session
struct ExamResult: Identifiable, Codable {
    let id: UUID
    let date: Date
    let durationSeconds: Int
    let score: Int  // 0–100 percentage
    let totalQuestions: Int
    let correctCount: Int
    let categoryResults: [CategoryResult]
    
    var passed: Bool {
        score >= 50  // German exam passing threshold
    }
    
    var timePerQuestion: Int {
        totalQuestions > 0 ? durationSeconds / totalQuestions : 0
    }
}

struct CategoryResult: Codable {
    let categoryId: UUID
    let categoryName: String
    let correctCount: Int
    let totalCount: Int
    
    var score: Double {
        guard totalCount > 0 else { return 0 }
        return Double(correctCount) / Double(totalCount)
    }
}