// File: com.driveai.askfin/data/models/UserPerformanceStats.kt
package com.driveai.askfin.data.models

import com.driveai.askfin.data.models.QuestionCategory
import com.driveai.askfin.data.models.TrainingMode
import java.time.Instant

/**
 * User's aggregated training statistics.
 * 
 * Breakdown by category and mode computed at repository layer.
 * All accuracy values are normalized to 0.0–1.0.
 */
data class UserPerformanceStats(
    val userId: String,
    val totalAnswers: Int,
    val correctAnswers: Int,
    val accuracy: Float,  // 0.0–1.0
    val averageTimePerQuestion: Long,  // milliseconds
    val categoryBreakdown: Map<QuestionCategory, PerformanceBreakdown> = emptyMap(),
    val modeBreakdown: Map<TrainingMode, PerformanceBreakdown> = emptyMap(),
    val lastUpdated: Instant
) {
    /**
     * Breakdown by single dimension (category or mode).
     */
    data class PerformanceBreakdown(
        val totalAnswers: Int,
        val correctAnswers: Int,
        val accuracy: Float  // 0.0–1.0
    ) {
        init {
            require(totalAnswers >= 0) { "Total answers cannot be negative" }
            require(correctAnswers >= 0) { "Correct answers cannot be negative" }
            require(correctAnswers <= totalAnswers) { "Correct answers cannot exceed total" }
            require(accuracy in 0.0f..1.0f) { "Accuracy must be 0.0–1.0, got $accuracy" }
        }
    }
    
    init {
        require(userId.isNotBlank()) { "User ID cannot be blank" }
        require(totalAnswers >= 0) { "Total answers cannot be negative" }
        require(correctAnswers >= 0) { "Correct answers cannot be negative" }
        require(correctAnswers <= totalAnswers) { "Correct answers cannot exceed total" }
        require(accuracy in 0.0f..1.0f) { "Accuracy must be 0.0–1.0, got $accuracy" }
        require(averageTimePerQuestion >= 0) { "Average time cannot be negative" }
    }
    
    /**
     * Compute accuracy as percentage (0–100).
     */
    fun accuracyPercent(): Float = accuracy * 100f
    
    /**
     * Check if performance meets passing threshold.
     */
    fun isPassing(threshold: Float = 0.8f): Boolean = accuracy >= threshold
}