import Foundation

struct LearningStats {
    let totalQuestions: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let averageConfidence: Double

    var accuracyRate: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }

    var accuracyPercentage: Int { Int(accuracyRate * 100) }
    var averageConfidencePercentage: Int { Int(averageConfidence * 100) }

    static let empty = LearningStats(
        totalQuestions: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        averageConfidence: 0
    )
}
