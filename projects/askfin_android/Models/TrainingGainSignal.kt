data class TrainingGainSignal(
    val categoryName: String,
    val percentageGain: Float,          // +7 points
    val reasonCode: GainReasonCode,     // RECENT_CORRECT_ANSWERS, RETRIEVAL_PRACTICE, etc.
    val elaborationText: String,        // "You answered 4 recent Speed Limits Qs correctly"
    val nextReviewDays: Int,            // "Review again in 3 days to cement learning"
)

enum class GainReasonCode {
    RECENT_CORRECT_ANSWERS,    // Testing effect
    SPACED_REPETITION,         // Ebbinghaus curve
    INTERLEAVING,              // Category mixing
    TIME_SINCE_LAST_SESSION,   // Recency boost
}

    val trainingGains: List<TrainingGainSignal> = emptyList(),  // NEW: explain gains
)