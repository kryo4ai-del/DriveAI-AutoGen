package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.unit.dp
import androidx.compose.material3.Text
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.Role

@Composable
private fun TimerDisplay(timeRemaining: Int) {
    val minutes = timeRemaining / 60
    val seconds = timeRemaining % 60
    val isWarning = timeRemaining < 300 // 5 minutes
    val isCritical = timeRemaining < 60   // 1 minute

    val timerColor = when {
        isCritical -> MaterialTheme.colorScheme.error
        isWarning -> MaterialTheme.colorScheme.errorContainer
        else -> MaterialTheme.colorScheme.primary
    }

    val criticalDesc = "Critical: $minutes minutes $seconds seconds remaining"
    val warningDesc = "Warning: $minutes minutes $seconds seconds remaining"
    val remainingDesc = "$minutes minutes $seconds seconds remaining"

    Card(
        colors = CardDefaults.cardColors(
            containerColor = timerColor.copy(alpha = 0.1f)
        ),
        modifier = Modifier
            .padding(8.dp)
            .semantics {
                contentDescription = when {
                    isCritical -> criticalDesc
                    isWarning -> warningDesc
                    else -> remainingDesc
                }
            }
    ) {
        Text(
            text = String.format("%02d:%02d", minutes, seconds),
            style = MaterialTheme.typography.labelLarge,
            color = timerColor,
            modifier = Modifier
                .padding(horizontal = 12.dp, vertical = 8.dp)
                .semantics { 
                    role = Role.Image
                },
            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
        )
    }
}