package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.runtime.remember
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.animation.core.tween
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseInOutQuad
import androidx.compose.foundation.layout.Row
import androidx.compose.ui.draw.scale
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import kotlin.math.absoluteValue
import kotlin.math.roundToInt

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