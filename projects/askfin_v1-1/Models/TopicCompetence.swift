import Foundation

/// Snapshot of a learner's performance for one topic area.
struct TopicCompetence: Codable, Identifiable {
    let topic: TopicArea
    var totalAnswers: Int
    var correctAnswers: Int
    /// Recency-weighted accuracy in [0.0, 1.0].
    var weightedAccuracy: Double
    /// Last time this topic was reviewed. Used by spacing/decay logic.
    var lastReviewedDate: Date?

    var id: String { topic.id }

    var competenceLevel: CompetenceLevel {
        .from(weightedAccuracy: weightedAccuracy, totalAnswers: totalAnswers)
    }

    var rawAccuracy: Double {
        guard totalAnswers > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalAnswers)
    }

    /// Normalised score in [0.0, 1.0] for ReadinessScoreService computation.
    var normalizedScore: Double { weightedAccuracy }

    init(
        id: String? = nil,
        topic: TopicArea,
        totalAnswers: Int = 0,
        correctAnswers: Int = 0,
        weightedAccuracy: Double = 0,
        lastReviewedDate: Date? = nil
    ) {
        self.topic = topic
        self.totalAnswers = totalAnswers
        self.correctAnswers = correctAnswers
        self.weightedAccuracy = weightedAccuracy
        self.lastReviewedDate = lastReviewedDate
    }
}
