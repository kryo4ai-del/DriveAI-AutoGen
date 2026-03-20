package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.animation.core.tween
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.animateIntAsState
import androidx.compose.material3.MaterialTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.runtime.getValue

@Composable
fun ReadinessCircle(
    score: Int,
    modifier: Modifier = Modifier,
    strokeWidth: Dp = 12.dp,
    isLoading: Boolean = false
) {
    val clampedScore = score.coerceIn(0, 100)

    val animatedScore by animateIntAsState(
        targetValue = clampedScore,
        animationSpec = tween(durationMillis = 1500, easing = EaseOutCubic),
        label = "readinessScoreAnimation"
    )

    val progressColor = when {
        animatedScore >= 90 -> MaterialTheme.colorScheme.primary
        animatedScore >= 75 -> MaterialTheme.colorScheme.tertiary
        animatedScore >= 60 -> MaterialTheme.colorScheme.secondary
        else -> MaterialTheme.colorScheme.error
    }

    val contentDescriptionText = buildString {
        append("Readiness score: $animatedScore percent. ")
        when {
            animatedScore >= 90 -> append("You are ready to test.")
            animatedScore >= 75 -> append("Great progress!")
            animatedScore >= 60 -> append("Good start.")
            else -> append("Keep practicing.")
        }
    }

    Box(
        modifier = modifier
            .aspectRatio(1f)
            .semantics {
                contentDescription = contentDescriptionText
                progressBarRangeInfo = ProgressBarRangeInfo(
                    current = animatedScore.toFloat(),
                    range = 0f..100f,
                    steps = 0
                )
            }
            // ... rest of drawBehind logic
    )
}