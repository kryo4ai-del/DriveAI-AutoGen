import Foundation

enum QuizResultError: Error {
    case insufficientData
    case invalidScore
}

protocol ResultUpdatable {
    // Protocol for potential methods to update result types
}

struct QuizResult: ResultUpdatable {
    let totalQuestions: Int
    let correctAnswers: Int
    
    var score: Double {
        guard totalQuestions > 0 else { return 0.0 } // Prevent division by zero
        return Double(correctAnswers) / Double(totalQuestions) * 100.0
    }
}