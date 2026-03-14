import Foundation

/// Session tuning parameters. Consumed by TrainingSessionViewModel.
struct TrainingConfig {
    let minimumQuestions: Int
    let maximumQuestions: Int
    let spacingQueueWeight: Double
    let weaknessWeight: Double
    let recencyDecay: Double

    /// Remainder after spacing and weakness slots are allocated.
    var coverageWeight: Double {
        1.0 - spacingQueueWeight - weaknessWeight
    }

    // ISSUE-06 FIX: assert (removed in release) instead of precondition (always fires).
    init(
        minimumQuestions: Int,
        maximumQuestions: Int,
        spacingQueueWeight: Double,
        weaknessWeight: Double,
        recencyDecay: Double
    ) {
        assert(
            spacingQueueWeight + weaknessWeight <= 1.0,
            "spacingQueueWeight + weaknessWeight must not exceed 1.0"
        )
        assert(
            minimumQuestions > 0 && minimumQuestions <= maximumQuestions,
            "minimumQuestions must be positive and ≤ maximumQuestions"
        )
        self.minimumQuestions   = minimumQuestions
        self.maximumQuestions   = maximumQuestions
        self.spacingQueueWeight = spacingQueueWeight
        self.weaknessWeight     = weaknessWeight
        self.recencyDecay       = recencyDecay
    }

    static let standard = TrainingConfig(
        minimumQuestions: 5,
        maximumQuestions: 10,
        spacingQueueWeight: 0.40,
        weaknessWeight: 0.40,
        recencyDecay: 0.85
    )
}