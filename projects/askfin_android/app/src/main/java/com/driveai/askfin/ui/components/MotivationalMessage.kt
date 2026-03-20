package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.res.stringResource
import com.driveai.askfin.R
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.LiveRegionMode

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