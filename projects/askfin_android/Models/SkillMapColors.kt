package com.driveai.skillmap.ui.theme

import androidx.compose.ui.graphics.Color
import com.driveai.skillmap.data.models.CompetenceLevel

object SkillMapColors {
    fun getCompetenceColor(level: CompetenceLevel): Color = when (level) {
        CompetenceLevel.NOVICE -> Color(0xFFEF5350)      // Red
        CompetenceLevel.BEGINNER -> Color(0xFFFFA726)    // Orange
        CompetenceLevel.INTERMEDIATE -> Color(0xFFFFD54F) // Yellow
        CompetenceLevel.PROFICIENT -> Color(0xFF81C784)   // Light Green
        CompetenceLevel.EXPERT -> Color(0xFF4CAF50)       // Green
    }

    fun getCompetenceColorByValue(value: Float): Color {
        return when {
            value <= 0.2f -> Color(0xFFEF5350)
            value <= 0.4f -> Color(0xFFFFA726)
            value <= 0.6f -> Color(0xFFFFD54F)
            value <= 0.8f -> Color(0xFF81C784)
            else -> Color(0xFF4CAF50)
        }
    }
}