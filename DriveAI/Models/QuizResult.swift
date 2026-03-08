import Foundation

struct QuizResult {
    let totalQuestions: Int
    let correctAnswers: Int
    
    // Computes the score percentage
    var score: Double {
        return Double(correctAnswers) / Double(totalQuestions) * 100.0
    }
}