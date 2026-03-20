package com.driveai.askfin.ui.components

@Composable
private fun MotivationalMessage(score: Int) {
    val (messageId, containerColor) = when {
        score >= 90 -> R.string.readiness_excellent to MaterialTheme.colorScheme.primaryContainer
        score >= 75 -> R.string.readiness_great to MaterialTheme.colorScheme.secondaryContainer
        score >= 60 -> R.string.readiness_good to MaterialTheme.colorScheme.tertiaryContainer
        else -> R.string.readiness_keep_trying to MaterialTheme.colorScheme.errorContainer
    }

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 16.dp)
            .semantics {
                liveRegion = LiveRegionMode.Assertive // Announce changes immediately
            },
        color = containerColor,
        shape = RoundedCornerShape(12.dp)
    ) {
        Text(
            text = stringResource(messageId),
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            textAlign = TextAlign.Center,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onTertiaryContainer
        )
    }
}