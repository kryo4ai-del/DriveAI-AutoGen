import Foundation

/// A question enriched with user metrics and focus area information
struct QuestionWithMetrics {
    let question: Question
    let userAccuracyPercent: Int?
    let isHighFocusArea: Bool

    var metadata: QuestionMetadata {
        QuestionMetadata(
            examFrequencyPercent: question.examFrequencyPercent,
            userAccuracyPercent: userAccuracyPercent,
            isHighFocusArea: isHighFocusArea,
            officialSourceLabel: question.officialSourceLabel
        )
    }
}