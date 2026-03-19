package com.driveai.askfin.domain.services

import kotlin.math.sqrt
import kotlin.math.exp

/**
 * Statistical utility for confidence intervals using Wilson score method.
 * Extracted for testability and reusability.
 */
class ConfidenceIntervalCalculator {
    
    /**
     * Computes 95% confidence interval using Wilson score (binomial proportion).
     * More accurate than normal approximation, especially for small samples.
     *
     * @param correctCount Number of correct answers
     * @param totalCount Total answer count
     * @param confidenceLevel Z-score for confidence (1.96 for 95%)
     * @return Confidence interval with bounds and margin
     */
    fun calculate(
        correctCount: Int,
        totalCount: Int,
        confidenceLevel: Float = 1.96f
    ): ConfidenceInterval {
        require(correctCount >= 0 && totalCount > 0) {
            "Invalid counts: correct=$correctCount, total=$totalCount"
        }
        require(correctCount <= totalCount) {
            "Correct count cannot exceed total count"
        }

        val n = totalCount.toDouble()
        val p = correctCount.toDouble() / n
        val z = confidenceLevel.toDouble()

        // Wilson score interval formula
        val center = (p + (z * z) / (2 * n)) / (1 + (z * z) / n)
        val margin = (z / (1 + (z * z) / n)) * 
            sqrt((p * (1 - p) / n) + (z * z / (4 * n * n)))

        val lowerProp = (center - margin).coerceIn(0.0, 1.0)
        val upperProp = (center + margin).coerceIn(0.0, 1.0)

        return ConfidenceInterval(
            lowerBound = (lowerProp * 100).toFloat(),
            upperBound = (upperProp * 100).toFloat(),
            margin = ((upperProp - lowerProp) / 2 * 100).toFloat()
        )
    }
}

    val upperBound: Float,  // [0..100]
    val margin: Float       // [0..50] percentage points
) {
    init {
        require(lowerBound in 0f..100f) { "Lower bound out of range" }
        require(upperBound in 0f..100f) { "Upper bound out of range" }
        require(lowerBound <= upperBound) { "Lower bound must be ≤ upper bound" }
    }
}