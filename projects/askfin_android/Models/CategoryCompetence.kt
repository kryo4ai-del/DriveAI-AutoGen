/**
 * Represents competence metrics for a single question category.
 * 
 * **Single Source-of-Truth:** competenceLevel is derived from accuracyRate + optional modifiers,
 * never stored independently. This prevents deserialization inconsistencies.
 */
data class CategoryCompetence(
    val category: QuestionCategory,
    val totalAnswered: Int,
    val correctAnswers: Int,
    val lastPracticed: LocalDateTime? = null,
    /**
     * Optional modifier: time-decay factor [0.0, 1.0].
     * Allows competence to slightly decrease if user hasn't practiced recently.
     * Default 1.0 = no decay.
     */
    val timeDecayFactor: Float = 1.0f
) {
    init {
        // Validate at construction time
        require(totalAnswered >= 0) { "totalAnswered must be >= 0, got $totalAnswered" }
        require(correctAnswers >= 0) { "correctAnswers must be >= 0, got $correctAnswers" }
        require(correctAnswers <= totalAnswered) {
            "correctAnswers ($correctAnswers) cannot exceed totalAnswered ($totalAnswered)"
        }
        require(timeDecayFactor in 0.0f..1.0f) {
            "timeDecayFactor must be in [0.0, 1.0], got $timeDecayFactor"
        }
    }

    /**
     * Computed property: accuracy rate (0.0–1.0).
     * Returns 0f if no questions answered.
     */
    val accuracyRate: Float
        get() = if (totalAnswered > 0) {
            (correctAnswers.toFloat() / totalAnswered).coerceIn(0.0f, 1.0f)
        } else {
            0.0f
        }

    /**
     * Computed property: competence level (0.0–1.0).
     * **Single source-of-truth:** derived from accuracy + time decay, never stored.
     * This ensures consistency across serialization/deserialization.
     */
    val competenceLevel: Float
        get() = (accuracyRate * timeDecayFactor).coerceIn(0.0f, 1.0f)

    /**
     * Computed property: derived proficiency level from competence score.
     */
    val level: CompetenceLevel
        get() = CompetenceLevel.fromScore(competenceLevel)

    /**
     * Validates internal consistency.
     * Note: competenceLevel is computed, so no validation needed for it.
     */
    fun isValid(): Boolean =
        totalAnswered >= 0 &&
        correctAnswers >= 0 &&
        correctAnswers <= totalAnswered &&
        timeDecayFactor in 0.0f..1.0f
}