data class ExamReadinessIndicator(
    val overallPercentage: Float,      // 67%
    val status: ReadinessStatus,       // NOT_READY / ALMOST_THERE / READY
    val gapAnalysis: String,           // "3 points away from exam threshold"
    val categoriesBlockingExam: List<String>, // ["Speed Limits"] — prevent you from passing
    val microMessage: String,           // "You're 3 points away. Master Speed Limits to unlock 70%."
)

enum class ReadinessStatus {
    NOT_READY,      // <60%
    ALMOST_THERE,   // 60-69%
    READY,          // 70%+
}