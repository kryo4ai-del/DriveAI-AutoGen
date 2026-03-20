package com.driveai.askfin.data.models

val percentage: Float
    get() = if (total == 0) Float.NaN else (correct.toFloat() / total) * 100f

// Or sealed class for stricter typing:
sealed class CategoryResult {
    data class Attempted(val percentage: Float) : CategoryResult()
    object NotAttempted : CategoryResult()
}