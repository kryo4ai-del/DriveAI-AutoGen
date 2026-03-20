package com.driveai.askfin.data.models

val percentage: Float
    get() = if (total == 0) {
        Float.NaN // explicit "no data"
    } else {
        (correct.toFloat() / total) * 100f
    }

// Or with sealed class for clarity:
sealed class CategoryScore(val category: QuestionCategory) {
    data class Scored(
        override val category: QuestionCategory,
        val correct: Int,
        val total: Int
    ) : CategoryScore(category) {
        val percentage = (correct.toFloat() / total) * 100f
    }
    data class NoAttempts(override val category: QuestionCategory) : CategoryScore(category)
}