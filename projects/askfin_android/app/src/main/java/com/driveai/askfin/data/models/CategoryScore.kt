package com.driveai.askfin.data.models

// Or with sealed class for clarity:
sealed class CategoryScore(val category: QuestionCategory) {
    data class Scored(
        val scoredCategory: QuestionCategory,
        val correct: Int,
        val total: Int
    ) : CategoryScore(scoredCategory) {
        val percentage = (correct.toFloat() / total) * 100f
    }
    data class NoAttempts(val noAttemptsCategory: QuestionCategory) : CategoryScore(noAttemptsCategory)
}