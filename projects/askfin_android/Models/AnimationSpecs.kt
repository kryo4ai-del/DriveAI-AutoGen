package com.driveai.askfin.ui.theme

import androidx.compose.animation.core.AnimationSpec
import androidx.compose.animation.core.EaseInOutQuad
import androidx.compose.animation.core.tween

object AnimationSpecs {
    const val FAST_DURATION = 150
    const val NORMAL_DURATION = 300
    const val SLOW_DURATION = 500

    val FAST: AnimationSpec<Float> = tween(FAST_DURATION, easing = EaseInOutQuad)
    val NORMAL: AnimationSpec<Float> = tween(NORMAL_DURATION, easing = EaseInOutQuad)
    val SLOW: AnimationSpec<Float> = tween(SLOW_DURATION, easing = EaseInOutQuad)

    val MILESTONE_UNLOCK: AnimationSpec<Float> = tween(
        durationMillis = 400,
        easing = EaseInOutQuad
    )
}

object ColorPalettes {
    // Score color mapping
    fun getScoreColor(score: Int, maxScore: Int = 100): androidx.compose.ui.graphics.Color {
        val percentage = (score.toFloat() / maxScore) * 100
        return when {
            percentage >= 81f -> androidx.compose.ui.graphics.Color(0xFF4CAF50)   // Green
            percentage >= 61f -> androidx.compose.ui.graphics.Color(0xFF2196F3)   // Blue
            percentage >= 41f -> androidx.compose.ui.graphics.Color(0xFFFFC107)   // Amber
            percentage >= 21f -> androidx.compose.ui.graphics.Color(0xFFFF9800)   // Orange
            else -> androidx.compose.ui.graphics.Color(0xFFE53935)                // Red
        }
    }
}