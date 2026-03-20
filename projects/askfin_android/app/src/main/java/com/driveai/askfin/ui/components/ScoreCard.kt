package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription

@Composable
fun ScoreCard(score: ReadinessScore) {
    Text(
        text = "Score: ${score.overallScore}",
        modifier = Modifier
            .semantics {
                contentDescription = "Overall score: ${score.overallScore}% recorded at ${score.getFormattedTimestamp()}"
            }
    )
}