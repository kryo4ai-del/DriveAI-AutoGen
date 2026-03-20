package com.driveai.askfin.ui.components

@Composable
fun TrendArrow(trendPercentage: Float, modifier: Modifier = Modifier) {
    val scaleAnimation = remember { Animatable(0.8f) }
    
    LaunchedEffect(trendPercentage) {
        scaleAnimation.animateTo(
            targetValue = 1.1f,
            animationSpec = tween(500, easing = EaseInOutQuad)
        )
    }
    
    Row(
        modifier = modifier
            .scale(scaleAnimation.value)
            .semantics { contentDescription = getTrendDescription(trendPercentage) }
    ) { /* ... */ }
}

private fun getTrendDescription(trendPercentage: Float): String = when {
    trendPercentage > 0 -> "Score improved by ${trendPercentage.roundToInt()}%"
    trendPercentage < 0 -> "Score decreased by ${trendPercentage.absoluteValue.roundToInt()}%"
    else -> "No change in score"
}