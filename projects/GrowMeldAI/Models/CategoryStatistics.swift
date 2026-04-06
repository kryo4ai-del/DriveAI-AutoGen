import Foundation

struct CategoryStatistics {
    let categoryName: String
    let totalQuestions: Int
    let correctAnswers: Int
    var accuracy: Double { totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) : 0 }
}
