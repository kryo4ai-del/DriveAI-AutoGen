package com.driveai.askfin.data.models
import kotlin.math.sqrt

data class ConfidenceInterval(
    val lowerBound: Float,  // [0..100]
    val upperBound: Float,  // [0..100]
    val margin: Float       // [0..50] (as percentage points, not proportion)
)

private fun calculateConfidenceInterval(
    answers: List<UserAnswer>,
    score: Double
): ConfidenceInterval {
    val n = answers.size.toDouble()
    val p = score / 100.0
    val z = 1.96

    val numerator = 2.0 * n * p + (z * z)
    val denominator = 2.0 * (n + z * z)
    val sqrtTerm = sqrt((z * z * p * (1 - p) / n) + (z * z * z * z / (4 * n * n)))

    val lowerProp = (numerator - 2.0 * n * sqrtTerm) / denominator
    val upperProp = (numerator + 2.0 * n * sqrtTerm) / denominator

    // Convert to percentage scale [0..100]
    val lower = (lowerProp * 100.0).toFloat().coerceIn(0f, 100f)
    val upper = (upperProp * 100.0).toFloat().coerceIn(0f, 100f)
    val margin = (upper - lower) / 2f

    return ConfidenceInterval(
        lowerBound = lower,
        upperBound = upper,
        margin = margin
    )
}

    val confidenceInterval: ConfidenceInterval,  // ← Changed from `confidence: Float`
    val sampleSize: Int
) {
    val isSignificant: Boolean get() = sampleSize >= 5
    val marginOfError: Float get() = confidenceInterval.margin
}