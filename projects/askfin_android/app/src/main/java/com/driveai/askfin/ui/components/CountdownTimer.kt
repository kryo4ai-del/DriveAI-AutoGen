package com.driveai.askfin.ui.components

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