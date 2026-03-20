package com.driveai.askfin.data.models

// In repository interface
/**
 * Requires historical score snapshots.
 * Implementation must query Room for score history.
 */
suspend fun calculateTrend(): Result<ReadinessTrend>

// In data models
data class ReadinessScoreSnapshot(
    val score: Float,
    val timestamp: LocalDateTime
)