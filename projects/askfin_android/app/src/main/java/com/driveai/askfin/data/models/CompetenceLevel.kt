package com.driveai.askfin.data.models

/**
 * Enum representing competence proficiency levels with inclusive ranges.
 * Ranges are [minThreshold, maxThreshold).
 * Example: PROFICIENT covers [0.8, 0.95), EXPERT covers [0.95, 1.0].
 */
enum class CompetenceLevel(
    val minThreshold: Float,
    val maxThreshold: Float,
    val displayName: String
) {
    BEGINNER(0.0f, 0.4f, "Beginner"),
    DEVELOPING(0.4f, 0.6f, "Developing"),
    COMPETENT(0.6f, 0.8f, "Competent"),
    PROFICIENT(0.8f, 0.95f, "Proficient"),
    EXPERT(0.95f, 1.0f, "Expert");

    companion object {
        private val SORTED_LEVELS = CompetenceLevel.entries.sortedBy { it.minThreshold }

        /**
         * Returns the [CompetenceLevel] for a given competence score (0.0–1.0).
         * Uses [minThreshold] inclusive comparison to avoid floating-point boundary ambiguity.
         */
        fun fromScore(score: Float): CompetenceLevel {
            require(score in 0.0f..1.0f) {
                "Score must be in [0.0, 1.0], got $score"
            }
            // Return the highest-threshold level where score >= minThreshold
            return SORTED_LEVELS.lastOrNull { score >= it.minThreshold }
                ?: BEGINNER // Safety fallback (unreachable due to BEGINNER.minThreshold = 0.0f)
        }
    }
}