import Foundation

struct TrafficSignStats {
    let totalSignsReviewed: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let averageConfidence: Double

    /// Only computed from learning-mode entries that have a user answer.
    var accuracyRate: Double {
        let answered = correctAnswers + incorrectAnswers
        guard answered > 0 else { return 0 }
        return Double(correctAnswers) / Double(answered)
    }

    var accuracyPercentage: Int { Int(accuracyRate * 100) }
    var averageConfidencePercentage: Int { Int(averageConfidence * 100) }

    /// Number of entries answered in learning mode
    var learningModeAnswers: Int { correctAnswers + incorrectAnswers }

    static let empty = TrafficSignStats(
        totalSignsReviewed: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        averageConfidence: 0
    )
}
