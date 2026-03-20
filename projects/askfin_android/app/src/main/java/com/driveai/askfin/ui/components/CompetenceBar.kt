package com.driveai.askfin.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width  // FIX-001: Added missing import
import androidx.compose.foundation.semantics.semantics
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.role
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.LocalContentColor
import androidx.compose.ui.platform.LocalAccessibilityManager
import com.driveai.askfin.data.models.CompetenceLevel
import com.driveai.askfin.ui.theme.SkillMapColors
import androidx.compose.ui.semantics.semantics

@Composable
fun CompetenceBar(
    currentLevel: Float,
    targetLevel: Float,
    competenceLevel: CompetenceLevel,
    skillName: String,
    modifier: Modifier = Modifier,
    progressAnimationDurationMillis: Int = 800,  // FIX-010: Separate animation durations
    colorAnimationDurationMillis: Int = 400
) {
    // FIX-002: Animate progress
    val animatedProgress by animateFloatAsState(
        targetValue = currentLevel.coerceIn(0f, 1f),
        animationSpec = tween(durationMillis = progressAnimationDurationMillis),
        label = "SkillProgressAnimation"
    )

    // FIX-002: Animate color for current level
    val barColor by animateColorAsState(
        targetValue = SkillMapColors.getCompetenceColorByValue(currentLevel),
        animationSpec = tween(durationMillis = colorAnimationDurationMillis),
        label = "SkillColorAnimation"
    )

    // FIX-002: ANIMATE target color, not just static
    val targetBarColor by animateColorAsState(
        targetValue = SkillMapColors.getCompetenceColorByValue(targetLevel),
        animationSpec = tween(durationMillis = colorAnimationDurationMillis),
        label = "TargetColorAnimation"
    )

    val backgroundColor = Color.Gray.copy(alpha = 0.2f)
    val progressPercentage = (animatedProgress * 100).toInt()

    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = skillName,
                style = MaterialTheme.typography.labelMedium,
                modifier = Modifier.weight(1f)
            )
            Text(
                text = "$progressPercentage%",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        // FIX-007: Add WCAG 2.1 AA compliant accessibility role
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(24.dp)
                .background(backgroundColor, RoundedCornerShape(12.dp))
                .semantics {
                    role = androidx.compose.ui.semantics.Role.ProgressBar
                    progressBarRangeInfo = ProgressBarRangeInfo(
                        current = animatedProgress,
                        range = 0f..1f,
                        steps = 0
                    )
                    contentDescription = buildString {
                        append("$skillName competence: $progressPercentage%. ")
                        append("Level: ${competenceLevel.name}. ")
                        append("Target: ${(targetLevel * 100).toInt()}%")
                    }
                }
        ) {
            // Current progress (animated)
            Box(
                modifier = Modifier
                    .fillMaxWidth(animatedProgress)
                    .height(24.dp)
                    .background(barColor, RoundedCornerShape(12.dp))
            )

            // Target level indicator (right edge line)
            if (targetLevel > currentLevel) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(targetLevel)
                        .height(24.dp)
                        .padding(end = 2.dp),
                    contentAlignment = Alignment.CenterEnd
                ) {
                    Box(
                        modifier = Modifier
                            .width(3.dp)  // FIX-001: Now imported correctly
                            .height(24.dp)
                            .background(targetBarColor.copy(alpha = 0.7f))
                    )
                }
            }
        }

        // Competence level badge
        Text(
            text = competenceLevel.name.uppercase(),
            style = MaterialTheme.typography.labelSmall,
            color = barColor,
            modifier = Modifier.padding(top = 4.dp)
        )
    }
}