package com.driveai.askfin.ui.components

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

    Card(
        colors = CardDefaults.cardColors(
            containerColor = timerColor.copy(alpha = 0.1f)
        ),
        modifier = Modifier
            .padding(8.dp)
            .semantics {
                contentDescription = when {
                    isCritical -> stringResource(R.string.timer_critical, minutes, seconds)
                    isWarning -> stringResource(R.string.timer_warning, minutes, seconds)
                    else -> stringResource(R.string.timer_remaining, minutes, seconds)
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
                    role = Role.ProgressIndicator
                },
            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
        )
    }
}