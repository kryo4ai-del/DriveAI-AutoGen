package com.driveai.askfin.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Sealed state for screen-level state management.
 * Covers Loading → Success/Error lifecycle.
 */
sealed class ReadinessScreenState {
    object Loading : ReadinessScreenState()
    data class Success(val data: ReadinessUiState) : ReadinessScreenState()
    data class Error(val message: String) : ReadinessScreenState()
}

/**
 * Data model for ReadinessScore UI state.
 * All fields have sensible defaults for error resilience.
 */
    val trendDirection: TrendDirection = TrendDirection.STABLE,
    val percentChange: Int = 0,                      // -100 to +100
    val milestones: List<MilestoneUiModel> = emptyList(),
    val isRefreshing: Boolean = false,
    val error: String? = null
) {
    fun isValid(): Boolean = score in 0..100
}

@Entity(tableName = "milestones")
    val name: String,
    val description: String = "",
    val achievedDate: Long? = null  // null = not achieved
) {
    val isAchieved: Boolean get() = achievedDate != null
}

enum class TrendDirection {
    UP, DOWN, STABLE
}