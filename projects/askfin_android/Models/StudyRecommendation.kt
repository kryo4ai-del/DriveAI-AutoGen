data class StudyRecommendation(
    val categoryId: String,
    val categoryName: String,
    val reason: RecommendationReason,  // WHY this category next?
    val urgency: UrgencyLevel,         // CRITICAL / HIGH / MEDIUM
    val estimatedGainPoints: Int,      // Master this → +8% to exam readiness
    val estimatedSessionsNeeded: Int,  // 3 more 15-min sessions
)

enum class RecommendationReason {
    EXAM_CRITICAL,          // Low score + high-weight category
    NEAREST_TO_MASTERY,     // Already at 65%, push to 70%
    HIGHEST_FORGETTING_RISK, // High score but last reviewed 10+ days ago (Ebbinghaus decay)
    BEST_EXAM_ROI,          // Master this → biggest boost to overall readiness
}

enum class UrgencyLevel {
    CRITICAL,   // Exam in <7 days AND score <60%
    HIGH,       // Exam in <14 days AND score <70%
    MEDIUM,     // Score 70%+ but due for spaced review
}

    val nextStudyRecommendation: StudyRecommendation? = null,  // NEW: reduce choice paralysis
    val examReadinessPercent: Int = 0,                         // NEW: progress toward goal
    val examReadinessStatus: ExamReadinessStatus = ExamReadinessStatus.NOT_READY,  // NEW
)

enum class ExamReadinessStatus {
    NOT_READY,      // <60%
    ALMOST_THERE,   // 60-69% (critical zone)
    EXAM_READY,     // 70%+
}