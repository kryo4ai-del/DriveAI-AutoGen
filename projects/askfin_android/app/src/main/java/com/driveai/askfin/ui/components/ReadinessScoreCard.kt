package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription

@Composable
fun ReadinessScoreCard(score: ReadinessScore) {
    Column(
        modifier = Modifier
            .semantics {
                contentDescription = buildString {
                    append(score.getAccessibleScoreDescription())
                    append(". ")
                    append(score.getWeakAreasForA11y())
                }
            }
    ) {
        // Visual score display
    }
}