// data/models/ReadinessScoreHistory.kt
package com.driveai.askfin.data.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Historical snapshot of readiness score.
 * Used to calculate [ReadinessTrend] by comparing recent samples.
 */
@Entity(tableName = "readiness_score_history")
data class ReadinessScoreHistoryEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    
    @ColumnInfo(name = "score")
    val score: Float,
    
    @ColumnInfo(name = "recorded_at")
    val recordedAt: Long  // Epoch millis (compatible with Room converter)
)