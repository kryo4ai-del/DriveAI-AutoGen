package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.material3.Card
import androidx.compose.ui.Modifier
import androidx.compose.material3.MaterialTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp
import androidx.compose.material3.Text
import android.view.HapticFeedbackConstants
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.ui.draw.scale
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.animation.core.keyframes
import androidx.compose.runtime.getValue

interface HapticFeedback

@Composable
private fun CountdownTimer(
    seconds: Int,
    isLowTime: Boolean,
    hapticFeedback: HapticFeedback
) {
    val pulseScale by animateFloatAsState(
        targetValue = if (isLowTime && seconds > 0) 1.15f else 1.0f,
        animationSpec = infiniteRepeatable(
            animation = keyframes {
                durationMillis = 1000
                1.0f at 0
                1.15f at 500
                1.0f at 1000
            }
        ),
        label = "TimerPulse"
    )

    Card(
        modifier = Modifier
            .scale(pulseScale)  // ✅ Apply animation here
            .background(
                color = if (isLowTime) 
                    MaterialTheme.colorScheme.errorContainer
                else 
                    MaterialTheme.colorScheme.secondaryContainer,
                shape = RoundedCornerShape(8.dp)
            )
            .padding(8.dp),
        shape = RoundedCornerShape(8.dp)
    ) {
        Text(
            text = "$seconds s",
            style = MaterialTheme.typography.labelSmall,
            modifier = Modifier.semantics {
                contentDescription = "$seconds seconds remaining"
            }
        )
    }
}