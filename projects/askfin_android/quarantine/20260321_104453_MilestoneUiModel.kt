package com.driveai.askfin.data.models

/**
 * UI model for milestone display.
 * Pre-formatted dates and state flags for Composable simplicity.
 * Prevents Composable from handling formatting logic.
 */
data class MilestoneUiModel(
    val id: String,
    val name: String,
    val description: String,
    val achievedDateFormatted: String?,  // "Jan 15, 2025" or null
    val isAchieved: Boolean
)

data class Milestone(
    val id: String,
    val name: String,
    val description: String,
    val achievedDate: Any?,
    val isAchieved: Boolean
)

interface DateFormatter {
    fun formatMilestoneDate(date: Any): String
}

fun Milestone.toUiModel(
    formatter: DateFormatter
): MilestoneUiModel = MilestoneUiModel(
    id = this.id,
    name = this.name,
    description = this.description,
    achievedDateFormatted = this.achievedDate?.let { formatter.formatMilestoneDate(it) },
    isAchieved = this.isAchieved
)